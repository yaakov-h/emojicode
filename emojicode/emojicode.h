#pragma once

#include <Foundation/Foundation.h>

extern const NSUInteger ECBitsPerByte;

NS_INLINE NSUInteger MakeBinaryMask(NSUInteger numBits)
{
	return (1 << numBits) - 1;
}

NSArray * GetCharacterSet();
void AddCharactersInStringToMutableArray(NSMutableArray * array, const NSString * const string);

void RunEncode(NSArray * characters);
void RunDecode(NSArray * characters);