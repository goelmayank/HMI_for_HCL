 /*
Program for:
Display text string on LCD display
Pins used are:
LCD pin	|P8 port pin|	GPIO number	|
-------------------------------------
	D0	|	45		|	70
	D1	|	46		|	71
	D2	|	43		|	72
	D3	|	44		|	73
	D4	|	41		|	74
	D5	|	42		|	75
	D6	|	39		|	76
	D7	|	40		|	77
	
	EN	|	37		|	78
	RS	|	38		|	79
	RW	|	36		|	80

Program written by:	Kaustubh Bhave
Program date: 		2nd Oct,2014
*/
#include <stdio.h>
#include <stdlib.h>

int EN=78;
int RS=79;
int RW=80;
int bin_array[8]={0,0,0,0,0,0,0,0};
//char line   =|12345678901234567890|
char line2[20]="                    ";
char line1[20]="                    ";


void send_command();
void send_data();
void send_text();
void get_binary();
void get_text();

void main ()
{
	get_text();

	send_text(1,line1);
	send_text(2,line2);
}

void get_text()
{
	FILE *fp;
	int i;
	char line1_addr[50];
	char line2_addr[50];
	char ch;
	
	sprintf(line1_addr, "/home/debian/bin/data/ln1_lcd.txt");
	sprintf(line2_addr, "/home/debian/bin/data/ln2_lcd.txt");
	
	//Read line1 text from file
	fp=fopen(line1_addr,"r");
	if (fp==NULL)
		printf("Can not open file: ln1_lcd.txt!!");
	
	for (i=0;i<20;i++)
	{
		ch=fgetc(fp);
		line1[i]=ch;
		//printf("%c;",ch);
	}

	fclose(fp);

	
	//Read line2 text from file
	fp=fopen(line2_addr,"r");
	if (fp==NULL)
		printf("Can not open file: ln2_lcd.txt!!");
	
	for (i=0;i<20;i++)
	{
		ch=fgetc(fp);
		line2[i]=ch;
		//printf("%c;",ch);
	}

	fclose(fp);
	
	
	//printf("Line1: %s\n",line1);
	//printf("Line2: %s\n",line2);

}



void get_binary(int dec)
{
	int bin[]={0,0,0,0,0,0,0,0};
	int i=0,j;
		  
	while(dec>0)
	{
		bin[i]=dec%2;
		i++;
		dec=dec/2;
	}
		
	for(j=7;j>=0;j--)
	{     
		bin_array[7-j]=bin[j];
	}
}


void send_text (int line_number, char text[])
{
	int i,j=0,decimal_value,k;
	char ch,ascii[8];

		
	int cursor_line1[8]={1,0,0,0,0,0,0,0};//0x80h to move cursor to start of first line
	int cursor_line2[8]={1,1,0,0,0,0,0,0};//0xc0h to move cursor to start of second line
		
	if (line_number==1)
		send_command(&cursor_line1);	
	else
		send_command(&cursor_line2);

	for (i=0;i<20;i++)
	{
		ch=text[i];
		decimal_value=ch;
		//printf ("\n%c %d ",ch,decimal_value);	//print character and decimal value
		if ((decimal_value==0)|(decimal_value==9)|(decimal_value==255)|(decimal_value==10))
			decimal_value=32;
					
		get_binary(decimal_value);
		/*for (j=0;j<8;j++)
		{
			printf("%d",bin_array[j]);			//print binary value of character to be displayed
		}
		printf ("\n");*/
		send_data(&bin_array);
	}
}



void delay1()
{
int d1,d2;
for (d1=0;d1<5;d1++);
	//for (d2=0;d2<225;d2++);
}



void send_command(int *receive)			//send command to LCD ports
{
	FILE *fp;
	int i,pin,value;
	char gpio_value[50];
	int data[8];
	for (i=0;i<8;i++)
	{
		data[i]=*(receive+i);
	}
	
	
	// Send data to port pins
	pin=0;
	for (i=77;i>69;i--)
	{
		sprintf(gpio_value, "/sys/class/gpio/gpio%d/value",i);
		
		fp=fopen(gpio_value, "w");
		fprintf (fp,"%d",data[pin]);
		fclose (fp);
		pin++;
	}

	//RS low for command	
		value=0;
		sprintf(gpio_value, "/sys/class/gpio/gpio%d/value",RS);
		fp=fopen(gpio_value, "w");
		fprintf (fp,"%d",value);
		fclose (fp);

	//RW low for write
		value=0;
		sprintf(gpio_value, "/sys/class/gpio/gpio%d/value",RW);
		fp=fopen(gpio_value, "w");
		fprintf (fp,"%d",value);
		fclose (fp);

	//EN high to low pulse
		value=1;
		sprintf(gpio_value, "/sys/class/gpio/gpio%d/value",EN);
		fp=fopen(gpio_value, "w");
		fprintf (fp,"%d",value);
		fclose (fp);

	delay1();	
		
	//Pull EN low
		value=0;
		sprintf(gpio_value, "/sys/class/gpio/gpio%d/value",EN);
		fp=fopen(gpio_value, "w");
		fprintf (fp,"%d",value);
		fclose (fp);
		
	delay1();
	/*
	printf("\n command is: ");
	for (i=0;i<8;i++)
	{
		printf("%d",data[i]);
	}
	*/
}


void send_data(int *receive)	//send command to LCD ports
{
	FILE *fp;
	int i,pin,value;
	char gpio_value[50];
	int data[8];
	for (i=0;i<8;i++)
	{
		data[i]=*(receive+i);
	}
	
	
	// Send data to port pins
	pin=0;
	for (i=77;i>69;i--)
	{
		sprintf(gpio_value, "/sys/class/gpio/gpio%d/value",i);
		
		fp=fopen(gpio_value, "w");
		fprintf (fp,"%d",data[pin]);
		fclose (fp);
		pin++;
	}

	//RS high for data	
		value=1;
		sprintf(gpio_value, "/sys/class/gpio/gpio%d/value",RS);
		fp=fopen(gpio_value, "w");
		fprintf (fp,"%d",value);
		fclose (fp);

	//RW low for write
		value=0;
		sprintf(gpio_value, "/sys/class/gpio/gpio%d/value",RW);
		fp=fopen(gpio_value, "w");
		fprintf (fp,"%d",value);
		fclose (fp);

	//EN high to low pulse
		value=1;
		sprintf(gpio_value, "/sys/class/gpio/gpio%d/value",EN);
		fp=fopen(gpio_value, "w");
		fprintf (fp,"%d",value);
		fclose (fp);

	delay1();	
		
	//Pull EN low
		value=0;
		sprintf(gpio_value, "/sys/class/gpio/gpio%d/value",EN);
		fp=fopen(gpio_value, "w");
		fprintf (fp,"%d",value);
		fclose (fp);
		
	delay1();
	
	/*
	printf("\n data is: ");
	for (i=0;i<8;i++)
	{
		printf("%d",data[i]);
	}
	*/
}



