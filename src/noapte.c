
#include <luajit-2.0/lua.h>
#include <luajit-2.0/lualib.h>
#include <luajit-2.0/lauxlib.h>

#include <curses.h>

#define ERROR_STRING "Error: %s\n"

int curses_running = 0;

static int curses_init( lua_State *L )
{
	initscr();
	raw();
	noecho();
	keypad( stdscr, TRUE );
	curs_set( 0 );

#ifndef __WIN32
	use_default_colors();
#endif
	
	start_color();

	int i;
#ifndef __WIN32
	for( i = 0; i < 8; i++ )
	{
		init_pair( i, i, -1 );
	}
#else
	for( i = 0; i < 8; i++ )
	{
		init_pair( i, i, 0 );
	}
#endif

	curses_running = 1;

	int x, y;
	getmaxyx( stdscr, y, x );

	lua_pushinteger( L, x );
	lua_pushinteger( L, y );

	return 2;
}

static int curses_terminate( lua_State *L )
{
	(void) L;

	endwin();
	curses_running = 0;

	return 0;
}

static int curses_write( lua_State *L )
{
	int x = lua_tointeger( L, -3 ),
		y = lua_tointeger( L, -2 );
	const char *s = lua_tostring( L, -1 );

	mvaddstr( y, x, s );

	return 0;
}

static int curses_getch( lua_State *L )
{
	char s[2];
	int c = getch();

	switch( c )
	{
	case KEY_UP:
		lua_pushstring( L, "up" );
		break;
	case KEY_DOWN:
		lua_pushstring( L, "down" );
		break;
	case KEY_LEFT:
		lua_pushstring( L, "left" );
		break;
	case KEY_RIGHT:
		lua_pushstring( L, "right" );
		break;
	case '\n':
		lua_pushstring( L, "enter" );
		break;
	default:
		s[0] = c;
		s[1] = 0;
		lua_pushstring( L, s );	
	}

	return 1;
}

static int curses_attr( lua_State *L )
{
	int a = lua_tointeger( L, -1 );
	
	attrset( a );

	return 0;
}

static int curses_clear( lua_State *L )
{
	(void) L;

	clear();

	return 0;
}

static int curses_refresh( lua_State *L )
{
	(void) L;

	refresh();

	return 0;
}

void init_constants( lua_State *L )
{
	lua_getglobal( L, "curses" );

	lua_pushinteger( L, COLOR_PAIR( COLOR_BLACK ) );
	lua_setfield( L, -2, "black" );

	lua_pushinteger( L, COLOR_PAIR( COLOR_RED ) );
	lua_setfield( L, -2, "red" );

	lua_pushinteger( L, COLOR_PAIR( COLOR_GREEN ) );
	lua_setfield( L, -2, "green" );

	lua_pushinteger( L, COLOR_PAIR( COLOR_YELLOW ) );
	lua_setfield( L, -2, "yellow" );

	lua_pushinteger( L, COLOR_PAIR( COLOR_BLUE ) );
	lua_setfield( L, -2, "blue" );
	
	lua_pushinteger( L, COLOR_PAIR( COLOR_MAGENTA ) );
	lua_setfield( L, -2, "magenta" );
	
	lua_pushinteger( L, COLOR_PAIR( COLOR_CYAN ) );
	lua_setfield( L, -2, "cyan" );
	
	lua_pushinteger( L, COLOR_PAIR( COLOR_WHITE ) );
	lua_setfield( L, -2, "white" );

	lua_pushinteger( L, A_NORMAL );
	lua_setfield( L, -2, "normal" );

	lua_pushinteger( L, A_BOLD );
	lua_setfield( L, -2, "bold" );

	lua_pushinteger( L, A_REVERSE );
	lua_setfield( L, -2, "reverse" );
}

luaL_Reg curses[] = {
	{	"init",			curses_init },
	{	"terminate",	curses_terminate },
	{	"write",		curses_write },
	{	"getch",		curses_getch },
	{	"attr",			curses_attr },
	{	"clear",		curses_clear },
	{	"refresh",		curses_refresh },
	{	NULL,			NULL }
};

int main( int argc, char **argv )
{
	lua_State *L = lua_open();
	luaL_openlibs( L );

	luaL_register( L, "curses", curses );
	init_constants( L );

	int r;

	if( argc < 2 )
	{
		r = luaL_dofile( L, "lua/main.lua" );
	}
	else
	{
		r = luaL_dofile( L, argv[1] );
	}

	if( curses_running )
		endwin();

	if( r )
	{
		printf( ERROR_STRING, lua_tostring( L, -1 ) );
	}

	return 0;
}

