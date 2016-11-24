// lua wrapper for wiring pi
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include <wiringPi.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define MAX_TIMINGS	85

int data[5] = { 0, 0, 0, 0, 0 };

int read_dht_data(lua_State *L)
{
	int DHT_PIN = lua_tonumber(L, 1);
	uint8_t laststate	= HIGH;
	uint8_t counter		= 0;
	uint8_t j			= 0, i;

	piHiPri (99);
	data[0] = data[1] = data[2] = data[3] = data[4] = 0;
	pinMode(DHT_PIN, OUTPUT);
    digitalWrite(DHT_PIN, HIGH);
    delayMicroseconds(10000);
    digitalWrite(DHT_PIN, LOW);
    delayMicroseconds(18000);
    /* Then pull it up for 40 microseconds */
    digitalWrite(DHT_PIN, HIGH);
    delayMicroseconds(40);
    /* Prepare to read the pin */
	pinMode(DHT_PIN, INPUT);

	/* detect change and read data */
	for ( i = 0; i < MAX_TIMINGS; i++ )
	{
		counter = 0;
		while ( digitalRead( DHT_PIN ) == laststate )
		{
			counter++;
			delayMicroseconds( 1 );
			if ( counter == 255 )
			{
				break;
			}
		}

		laststate = digitalRead( DHT_PIN );
		if ( counter == 255 )
			break;

		/* ignore first 3 transitions */
		if ( (i >= 4) && (i % 2 == 0) )
		{
			/* shove each bit into the storage bytes */
			data[j / 8] <<= 1;
			if ( counter > 16 )
				data[j / 8] |= 1;
			j++;
		}
	}
	/*
	 * check we read 40 bits (8bit x 5 ) + verify checksum in the last byte
	 * print it out if data is good
	 */
	if ( (j >= 40) &&
	     (data[4] == ( (data[0] + data[1] + data[2] + data[3]) & 0xFF) ) )
	{
		float h = (float)((data[0] << 8) + data[1]) / 10;
		if ( h > 100 )
		{
			h = data[0];	// for DHT11
		}
		float c = (float)(((data[2] & 0x7F) << 8) + data[3]) / 10;
		if ( c > 125 )
		{
			c = data[2];	// for DHT11
		}
		if ( data[2] & 0x80 )
		{
			c = -c;
		}
		lua_pushnumber(L,h);
		lua_pushnumber(L,c);
		pinMode(DHT_PIN, OUTPUT);
		digitalWrite(DHT_PIN, HIGH);
		piHiPri (0);
		return(2);
	}else  {
		pinMode(DHT_PIN, OUTPUT);
		digitalWrite(DHT_PIN, HIGH);
		piHiPri (0);
		return(0);
	}
}

int main( void )
{
	return(0);
}

int fastReadPin(lua_State *L)
{
	int pin = lua_tonumber(L, 1);
	lua_pushnumber(L,digitalRead( pin ));
	return(1);
}

int PWMsetup(lua_State *L)
{
	int pin = 18
	pinMode(pin, PWM_OUTPUT);
	return(0);
}

int PWMset(lua_State *L)
{
	int r = lua_tonumber(L, 1);
	int c = lua_tonumber(L, 2);
	pwmSetRange(r);
	pwmSetClock(c) ;
	pwmWrite (18, 5);
	return(0);
}



int luaopen_source_readDHT (lua_State *L) {
	wiringPiSetupGpio();
	lua_register(L,"readDHT",read_dht_data);
	lua_register(L,"fastReadPin",fastReadPin);
	lua_register(L,"PWMsetup",PWMsetup);
	lua_register(L,"PWMset",PWMset);
	return 0;
}
