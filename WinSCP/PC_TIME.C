#include <time.h>
#include <stdio.h>
#include <string.h>
int main(void)
{
	time_t mytime;
	mytime = time(NULL);
	char* pc_time=ctime(&mytime);
	FILE *fp;
	char ch;
	fp=fopen("C:/HLC_files/current_time.txt","w");
	for(int i=0;i<strlen(pc_time);i++){
		ch=pc_time[i];	
		putc(ch,fp);
	}
	fclose(fp);
	return 0;
}
