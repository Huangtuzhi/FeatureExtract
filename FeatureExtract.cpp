#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <cmath>
#include <iostream>
#include <fstream>
#include <cstdio>
using namespace std;

#define   PI     3.1415926
#define   TPI    2*PI
#define   PREEMCOEF 0.9375
#define    N     256     //������������
#define    M     8       //DFT�������  

typedef struct _ExtractedFeature
{
	    float MFCC[12];
		int zcr;
		double En;
		double EnProduct;
}GetFeature;

typedef struct _TWavHeader  //wav��ʽ��Ƶ���ļ�ͷ
{ 
        int rId;    //��־����RIFF��
        int rLen;   //���ݴ�С,��������ͷ�Ĵ�С����Ƶ�ļ��Ĵ�С
        int wId;    //��ʽ���ͣ�"WAVE"��
        int fId;    //"fmt"

        int fLen;   //Sizeof(WAVEFORMATEX)

        short wFormatTag;       //�����ʽ������WAVE_FORMAT_PCM��WAVEFORMAT_ADPCM��
        short nChannels;        //��������������Ϊ1��˫����Ϊ2
        int nSamplesPerSec;   //����Ƶ��
        int nAvgBytesPerSec;  //ÿ���������
        short nBlockAlign;      //�����
        short wBitsPerSample;   //WAVE�ļ��Ĳ�����С
        int dId;              //"data"
        int wSampleLength;    //��Ƶ���ݵĴ�С
}TWavHeader; 

void  PreEmphasise (double *s, double k);
void  GenHamWindow (int frameSize);
void  Ham (double *s,int frameSize);
double MyFFT(double *s,double *out); //��������ֵEn
void  TrigFilter(double* in,double* out);
void  Bank(double *in,double *out);//��ȡ12��MFCCϵ��
int   GetZCR(double * in,int len); //��ȡ������

int    ipframesize=256; //����֡�ĳ���
double  hamWin[512];
double  Value[N];//FFT�㷨����ķ�����
double En=0;

int main()
{
 TWavHeader waveheader;
 FILE *sourcefile;
 ofstream outfile("1.txt");
 sourcefile=fopen("1.wav","rb");
 fread(&waveheader,sizeof(struct _TWavHeader),1,sourcefile);
 cout<<waveheader.nChannels<<endl;
 cout<<waveheader.wBitsPerSample<<endl;
 cout<<waveheader.nSamplesPerSec<<endl;
 cout<<sizeof(struct _TWavHeader)<<endl;
 
 short buffer[256];
 double singledata[256];
 double FFTCoff[256];
 double TrigCoff[24]={0};
 double BankCoff[12]={0};
 int   zcr=0;
 double energe=0;
 double enproduct=0;
 int j;
 int flag=1;
 while(flag==1 && fread(buffer,sizeof(short),ipframesize,sourcefile)==ipframesize)//�ȴ����ݶ���һ����256���ֽڡ��ļ�ָ���ƶ���������������
 {   flag=0;
	 for(int i=0;i<ipframesize;i++) 
	 {
		 //singledata[i]=(3.0518/100000)*buffer[i];
		 singledata[i]=buffer[i];
		 printf("Data Index %d:%lf\r\n",i,singledata[i]);
	 }


PreEmphasise (singledata, PREEMCOEF);
Ham (singledata, ipframesize);//�Ӻ�����
energe=MyFFT(singledata,FFTCoff);
TrigFilter(FFTCoff,TrigCoff);
Bank(TrigCoff,BankCoff);
zcr=GetZCR(singledata,ipframesize);   
enproduct=zcr*energe;
fseek(sourcefile,-256,SEEK_CUR);//�ļ�ָ�����

GetFeature Features;

for(j=0;j<12;j++)
{
	Features.MFCC[j]=BankCoff[j];
}
Features.En=energe;
Features.zcr=zcr;
Features.EnProduct=enproduct;

for(j=0;j<12;j++)
printf("bankcoff %f \r\n ",Features.MFCC[j]);
printf("\r\n");
printf("zcr %d\r\n",zcr);
printf("Energe %f\r\n",energe);
printf("EnProduct %f \r\n",enproduct);
printf("-------------------------------\r\n");
}
}


void PreEmphasise (double *s, double k)
{
   int i;
   float preE;//����ϵ��
   
   preE = k;
   for (i=ipframesize;i>=1;i--)
      s[i] -= s[i-1]*preE;
}

/* GenHamWindow: generate precomputed Hamming window function */
 void GenHamWindow (int frameSize)//������������ϵ��ȡ0.46��
{
   int i;
   float a;
   a = TPI / (frameSize - 1);
   for (i=1;i<=frameSize;i++)
      hamWin[i] = 0.54 - 0.46 * cos(a*(i-1));
}

//Ham: Apply Hamming Window to Speech frame s 
void Ham (double *s,int frameSize)
{
	
   int i;
   GenHamWindow(frameSize);
   s[0]=0.8000;//S[0]��һ����ֵ
   for (i=1;i<=frameSize;i++)
      s[i] *= hamWin[i];
}

double MyFFT(double *s,double *out)
{  
	float local_en=0;//���������ľֲ����� 

    float   x_i[N]={0}; 
	float  x_r[N];
	//bulk1
    int    p=1, q, i;
    int    bit_rev[ N ];  
    float   xx_r[ N ];   
    
    //bulk2
    int     cur_layer, gr_num, k;	//cur_layer������Ҫ����ĵ�ǰ�㣬gr_num����ǰ��Ŀ�����
    float   tmp_real, tmp_imag, temp;   // ��ʱ����, ��¼ʵ��
    float   tw1, tw2;// ��ת����,tw1Ϊ��ת���ӵ�ʵ��cos����, tw2Ϊ��ת���ӵ��鲿sin����.
    int    step;      // ����
    int    sample_num;   // ��������������(���㲻ͬ, ��Ϊ������������벻ͬ) 
    
    for(i=0;i<N;i++)
    x_r[i] =s[i] ;  //�������ݣ��˴���Ϊ256
 
    //bulk1
    bit_rev[ 0 ] = 0;
    while( p < N )
    {
       for(q=0; q<p; q++)  
       {
           bit_rev[ q ]     = bit_rev[ q ] * 2;
           bit_rev[ q + p ] = bit_rev[ q ] + 1;
       }
       p *= 2;
    }
    
    for(i=0; i<N; i++)  
		xx_r[ i ] = x_r[ i ];    
    for(i=0; i<N; i++)   
		x_r[i] = xx_r[ bit_rev[i] ];
   
     //bulk2
    /* �Բ�ѭ�� */
    for(cur_layer=1; cur_layer<=M; cur_layer++)
    {      
       /* ��ǰ��ӵ�ж��ٸ�����(gr_num) */
       gr_num = 1;
       i = M - cur_layer;
       while(i > 0)
       {
           i--;
           gr_num *= 2;
       }
       /* ÿ������������������N' */
       sample_num    = (int)pow(2, cur_layer); 
       /* ����. ������N'/2 */
       step       = sample_num/2;
       /*  */
       k = 0;
       /* �Կ�������ѭ�� */
       for(i=0; i<gr_num; i++)
       {//  �����������ѭ��, ע�����޺Ͳ��� 
            for(p=0; p<sample_num/2; p++)
           {   
              // ��ת����, ��Ҫ�Ż�...    
              tw1 = cos(2*PI*p/pow(2, cur_layer));
              tw2 = -sin(2*PI*p/pow(2, cur_layer));
              tmp_real = x_r[k+p];
              tmp_imag = x_i[k+p];
              temp = x_r[k+p+step];
              /* �����㷨 */
              x_r[k+p]   = tmp_real + ( tw1*x_r[k+p+step] - tw2*x_i[k+p+step] );
              x_i[k+p]   = tmp_imag + ( tw2*x_r[k+p+step] + tw1*x_i[k+p+step] );
              x_r[k+p+step]   = tmp_real - ( tw1* temp - tw2*x_i[k+p+step] );
              x_i[k+p+step]   = tmp_imag - ( tw2* temp + tw1*x_i[k+p+step] );
              
           }
           /* ����!:) */
           k += 2*step;
       }   
    }

    for(i=0;i<N;i++)           //����������
		out[i]=x_r[i]*x_r[i]+x_i[i]*x_i[i];
	for(i=0;i<N;i++)   
		local_en+=out[i]*out[i];
	return local_en;
}


void TrigFilter(double* in,double* out)//���������˲�ϵ��
{   int i;
    float var;
    int channel,pot; 
    float Fres[26];//24��ͨ
	float F[24][256]={0};
	float fh=4000; 
    float melf=2595*log(1+fh/700);
	
	for(i=0;i<26;i++)
	{
		Fres[i]=700*(exp((melf/2595)*i/25)-1);
    }

	for(channel=0;channel<24;channel++)
	{
		for(pot=0;pot<256;pot++)
		{   
			var=fh*(pot+1)/256;
			if( (Fres[channel]<=var)&&(var<=Fres[channel+1]) )
				F[channel][pot]=(var-Fres[channel])/(Fres[channel+1]-Fres[channel]);
			else if( (Fres[channel+1]<=var)&&(var<=Fres[channel+2]) )
                F[channel][pot]=(Fres[channel+2]-var)/(Fres[channel+2]-Fres[channel+1]);
            else F[channel][pot]=0;
		}
	}

	for(channel=0;channel<24;channel++)
	{  
		out[channel]=0;//�Ƚ��г�ʼ����Ȼ�����
		for(pot=0;pot<256;pot++)
		{   
			out[channel]+=in[pot]*F[channel][pot];
		}
  	out[channel]=log(out[channel]);
	}

}

void Bank(double *in,double *out)
{
	int i,j;
	float dctcoef[12][24];
	float win[12];
	float Wmax=0;
    for(i=0;i<12;i++)
	{
		for(j=0;j<24;j++)
		{
			dctcoef[i][j]=cos((2*j+1)*(i+1)*PI/(2*24));
		}
	}

	for(i=0;i<12;i++)
	{
		win[i]=1+6*sin((float)(PI*(i+1))/12);
		if(win[i]>Wmax)
			Wmax=win[i];
	}
    
	for(i=0;i<12;i++)
	{
		win[i]=win[i]/Wmax;//��һ��
	}

	for(i=0;i<12;i++)
	{
		for(j=0;j<24;j++)
		{
			out[i]+=dctcoef[i][j]*in[j];
		}
		out[i]=out[i]*win[i];
	}
}


int GetZCR(double * in,int len)  //�������㷨Ӧ�ú�Matlabһ������Ϊ�����������ݽ�ѵ����
{
	int zcr=0;
	int i;
    float delta=0.02;
    for(i=0;i<len-1;i++){
		if( (in[i]*in[i+1]<0) && (abs(in[i]-in[i+1])>delta) )
			zcr++;
	}
	return zcr;
}
