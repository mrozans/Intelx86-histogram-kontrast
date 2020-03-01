#include <stdio.h>
#include <stdlib.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_image.h>
#ifdef __cplusplus
extern "C" {
#endif
 void contrast(unsigned char *i1, int w, int h, int val);
 void histogram(unsigned char *i1, int w, int h);
#ifdef __cplusplus
}
#endif
char filename[30];
char outfilename[30];
FILE *input;
int choice;
int value = 1;
void func()
{
	// variables
	int i,j;
	int width, height;
	unsigned char *image1,*image2;
	char information[54];
  	FILE *output;
	fread(information, 1, 54, input);
	width = *(int*)(information+18);
	height = *(int*)(information+22);
	image1 = (unsigned char*) malloc(width*height*3);
	fread(image1, 1, width*height*3, input);
	fclose(input);
	// histogram operation
	if (choice == 1)
	{
		histogram(image1,width,height);
	}

	// contrast operation
	else if(choice == 2)
	{
		contrast(image1,width,height,value);
	}
	outfilename[0]='o';
	outfilename[1]='u';
	outfilename[2]='t';
	outfilename[3]='_';
	for (i=0; filename[i]!='\0'; i++) outfilename[i+4]=filename[i];
	outfilename[i+4]='\0';
	output = fopen(outfilename,"wb");
	*(int*)(information+18) = width;
	*(int*)(information+22) = height;
	fwrite(information, 1, 54, output);
	fwrite(image1, 1, width*height*3, output);
	fclose(output);
	free(image1);	
}

int main(int argc, char** argv)
{ 
	
	// argument check
	if (argc < 3)
	{
		printf("usage: ./program op_num input1.bmp [value|input2.bmp]\n");
		return 1;
	}
	choice = atoi(argv[1]);
	int i;
	for (i=0; argv[2][i]!='\0'; i++) filename[i]=argv[2][i];
	input = fopen(filename,"rb");
	func();

   	bool doexit = false;
	
	ALLEGRO_DISPLAY * display = NULL;
	ALLEGRO_BITMAP * image = NULL;
	ALLEGRO_EVENT_QUEUE *event_queue = NULL;
    
    	if( !al_init() ) 
	{
        	fprintf( stderr, "failed to initialize allegro!\n" );
        	return -1;
  	}

	
   	if(!al_install_keyboard()) 
	{
     		fprintf(stderr, "failed to initialize the keyboard!\n");
     		return -1;
  	 }
	
	if(!al_init_image_addon()) 
	{
      		fprintf( stderr, "failed to initialize al_init_image_addon!\n" );
      		return -1;
  	}
    
   	 display = al_create_display( 800, 600 );
    	if( !display ) 
	{
        	fprintf( stderr, "failed to create display!\n" );
        	return -1;
    	}

	event_queue = al_create_event_queue();
   	if(!event_queue) 
	{
     		fprintf(stderr, "failed to create event_queue!\n");
    		al_destroy_display(display);
     		return -1;
   	}


	image = al_load_bitmap(outfilename);

   	if(!image) 
	{
      		fprintf( stderr, "failed to get image!\n" );
      		al_destroy_display(display);
      	return 0;
   	}

	al_register_event_source(event_queue, al_get_display_event_source(display));
	al_register_event_source(event_queue, al_get_keyboard_event_source());
	
   	al_draw_bitmap(image,0,0,0);
    	al_flip_display();
	while(!doexit)
   	{
		bool redraw = false;
		ALLEGRO_EVENT ev;
     		al_wait_for_event(event_queue, &ev);
		if(ev.type == ALLEGRO_EVENT_DISPLAY_CLOSE) 
		{
         		break;
      		}
		
		else if(ev.type == ALLEGRO_EVENT_KEY_UP  && choice == 2) 
		{
			switch(ev.keyboard.keycode) 
			{
			    	case ALLEGRO_KEY_UP:
			       	value++;
				redraw = true;
			      	break;

			    	case ALLEGRO_KEY_DOWN:
			       	value--;
				redraw = true;
			       	break;

			    	case ALLEGRO_KEY_LEFT: 
			       	break;

			    	case ALLEGRO_KEY_RIGHT:
			       	break;
			}
      		}
		
		if(redraw && al_is_event_queue_empty(event_queue))
		{
			input = fopen(filename,"rb");
			func();
			image = al_load_bitmap(outfilename);
			al_clear_to_color(al_map_rgb(0,0,0));
   			al_draw_bitmap(image,0,0,0);
   			al_flip_display();	
		}
	}


   	al_destroy_display(display);
   	al_destroy_bitmap(image);
	al_destroy_event_queue(event_queue);
	return 0;
}
