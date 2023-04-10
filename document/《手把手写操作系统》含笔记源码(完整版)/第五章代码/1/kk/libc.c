/*/*******************************************************************************
**                                                                            **
**                     Jiedi(China nanjing)Ltd.                               **
**	               创建：丁宋涛 夏曹俊，此代码可用作为学习参考                **
*******************************************************************************/

/*****************************FILE INFOMATION***********************************
**
** Project       :从零开发操作系统：从加电自检到内核引导
** Contact       : xiacaojun@qq.com
**  博客   : http://blog.csdn.net/jiedichina
**	视频课程 : 网易云课堂	http://study.163.com/u/xiacaojun		
			   腾讯课堂		https://jiedi.ke.qq.com/				
			   csdn学院               http://edu.csdn.net/lecturer/lecturer_detail?lecturer_id=961	
**                                                51cto学院              http://edu.51cto.com/lecturer/index/user_id-12016059.html	
** 			   老夏课堂		http://www.laoxiaketang.com 
**                 
**  从零开发操作系统：从加电自检到内核引导    课程群 ：1041934556 加入群下载代码和学员交流
**                           微信公众号  : jiedi2007
**		头条号	 : 夏曹俊
**
*****************************************************************************
//！！！！！！！！！ 从零开发操作系统：从加电自检到内核引导 课程  QQ群：1041934556下载代码和学员交流*/

//我们使用c语言来扩展我们的内核
#include "stringio.h"
#define BUFLEN 16

extern void clearScreen();
extern void powerOFF();
extern void systime();
extern void drawPic();
extern void callPM();
//系统的启动界面
void startUp(){
	clearScreen();
	char* title = "MyTiny OS V1.1";
	char* subTitle = "Designed by Dst & Xcj";
	char* copyRight = "copyleft by GNU";
	char* hint = " System is ready.Press ENTER to start Shell";
	printInPos(title,strlen(title),5,23);
	printInPos(subTitle,strlen(subTitle),6,29);
	printInPos(copyRight,strlen(copyRight),8,35);
	printInPos(hint,strlen(hint),15,11);
}


//打印shell提示符
void promptString(){
	char* pmt_string = "MyTinyOS #";
	print(pmt_string);
}

void showHelp(){
	
	char *help_str=
	"Shell for MyTinyOS, Version 1.1 - on x86 PC\r\n"
	"This is a shell which is used for MyTinyOS。These shell Commands are defined as follows.Use `help` to see the list \r\n"
	"\r\n"
	" clear - clear the termianl \r\n"
	" time - get the currrent time \r\n"
	" drawpic - draw a animate pic \r\n"
	" poweroff - force shutdown the machine \r\n";
	print(help_str);
}

void shell(){
	clearScreen();
	showHelp();
	char cmdstr[BUFLEN+1] = {0};
	char cmd_fstword[BUFLEN+1] = {0};

	enum command {help,clear,time,drawpic,poweroff,enterpm};
	char* commands[] ={"help","clear","time","drawpic","poweroff","enterpm"};

	while(1){
		promptString();
		readToBuf(cmdstr,BUFLEN);
		getFirstWord(cmdstr,cmd_fstword);
		
		if(strcmp(cmd_fstword,commands[clear])==0){
			clearScreen();		
		}else if(strcmp(cmd_fstword,commands[enterpm])==0){
			callPM();
		}
		else if(strcmp(cmd_fstword,commands[time])==0){
			systime();
		}else if(strcmp(cmd_fstword,commands[drawpic])==0){
			drawPic();
			clearScreen();
		}else if(strcmp(cmd_fstword,commands[poweroff])==0){
			powerOFF();
		}else if(strcmp(cmd_fstword,commands[help])==0){
			showHelp();
		}else{
			if(cmd_fstword[0] !='\0'){
				char* errMsg = ": command not found \r\n";
				print(cmd_fstword);
				print(errMsg);
			}
		}

		
	
	}	
}
