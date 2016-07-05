#include<stdio.h>
#include<time.h>

void UART_Init()
{
	TMOD=Ox20;	//Timer1 in Mode2
	TH1=-3;	//9600 Baud rate at 11.0592MHz
	SCON=0x50;	//Aysnchronous mode 8-bit data and 1 stop bit 
	TR1=1;	//Turn ON the timer
}
char UART_RxChar()
{
	while(RI==0);
	RI=0;
	return(SBUF); //return the received char
}
void UART_TxChar(char ch)
{
	SBUF=ch; //Load the data to be transmitted
	while(TI==0);
	TI=0;
}
void UART_RxString(char *str_ptr)
{
	ch=UART_RxChar();
	UART_TxChar(ch);
	if((ch=='\r') || (ch=='\n'))
	{
		*str_ptr=0;
		break;
	}
	*str_ptr=ch;
	str_ptr++;
}
void UART_TxString(char *str_ptr)
{
	while(*str_ptr)
		UART_TxChar(*str_ptr++);	
}
void UART_RxNumber(char *str_ptr)
{
	while(*str_ptr)
		UART_TxChar(*str_ptr++);
}
void UART_TxNumber(unsigned int num)
{
	UART_TxChar((num/10000)+0x30);
	num=num%10000;
	UART_TxChar((num/1000)+0x30);
	num=num%1000;
	UART_TxChar((num/100)+0x30);
	num=num%100;
	UART_TxChar((num/10)+0x30);
	UART_TxChar((num%10)+0x30);
}
/* start the main program */
void main()
{
char msg[50];
time_t mytime;
UART_Init(); // function to initialzie UART
mytime = time(NULL);
msg= ctime(&mytime);
// while(1)
// {
// UART_TxString("\n\n\rEnter a new String: ");
// UART_RxString(msg);
// UART_TxString("\n\rEntered String: ");
UART_TxString(msg); //Transmit the received string
// }
getch();
}