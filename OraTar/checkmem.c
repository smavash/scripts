#include <stdio.h>
#include <malloc.h>

typedef struct cell {
        char value[1024];
        struct cell *next;
} Cell;
int main ()
{
	int size,i,j;
	char x[5];
	Cell *list=calloc(1,sizeof(Cell));
	Cell *temp=list;
	printf ("Enter Megs: ");
	scanf("%d",&size);

	
	for (i=0;i<size;i++)
	{
		for (j=0;j<1024;j++)
		{
			temp->next=calloc(1,sizeof(Cell));
			temp=temp->next;
		}
		printf ("Allocated %d Megs\n",i+1);
	}
	printf ("Press <ENTER> To Free Memory");
	getchar(); 
	getchar(); 

}

