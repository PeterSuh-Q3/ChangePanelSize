#define _GNU_SOURCE
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#ifndef TARGET
#define TARGET "/var/packages/Changepanelsize/target/bin/storagepanel.sh"
#endif
static int ok(const char*s){size_t i;if(!s||!*s||strlen(s)>32)return 0;for(i=0;s[i];i++)if(!((s[i]>='A'&&s[i]<='Z')||(s[i]>='a'&&s[i]<='z')||(s[i]>='0'&&s[i]<='9')||s[i]=='_'||s[i]=='X'||s[i]=='-'))return 0;return 1;}
int main(int n,char**v){if(n>3||(n>1&&!ok(v[1]))||(n>2&&!ok(v[2])))return 1;if(setuid(0))return 1;
#ifdef __linux__
clearenv();
#endif
setenv("PATH","/usr/bin:/bin:/usr/sbin:/sbin:/usr/syno/bin:/usr/syno/sbin",1);setenv("HOME","/root",1);if(n==1)execl(TARGET,TARGET,(char*)0);else if(n==2)execl(TARGET,TARGET,v[1],(char*)0);else execl(TARGET,TARGET,v[1],v[2],(char*)0);return 1;}
