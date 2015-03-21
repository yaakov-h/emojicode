#import <Foundation/Foundation.h>
#import "emojicode.h"

NSDictionary * BuildDecodeLookup(NSArray * characters)
{
	NSMutableDictionary * lookup = [[NSMutableDictionary alloc] initWithCapacity:characters.count];
	
	[characters enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		lookup[obj] = @(idx);
	}];
	
	return [lookup copy];
}

void RunDecode(NSArray * characters)
{
	NSUInteger numBitsCompressedIntoOneEmoji = (int)log2(characters.count);
	
	NSDictionary * lookup = BuildDecodeLookup(characters);
	
	NSFileHandle * stdinHandle = [[NSFileHandle alloc] initWithFileDescriptor:STDIN_FILENO closeOnDealloc:NO];
	NSData * inputData = [stdinHandle readDataToEndOfFile];
	NSString * inputStrings = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
	
	NSMutableArray * inputCharacters = [[NSMutableArray alloc] initWithCapacity:inputStrings.length];
	AddCharactersInStringToMutableArray(inputCharacters, inputStrings);
	
	NSUInteger scratchSpaceSize = roundup(inputCharacters.count * numBitsCompressedIntoOneEmoji, ECBitsPerByte) / ECBitsPerByte + 1;
	uint8_t * scratchSpace = (uint8_t *)malloc(scratchSpaceSize);
	memset(scratchSpace, 0, scratchSpaceSize);
	scratchSpace[scratchSpaceSize] = '\0';
	NSUInteger scratchIndex = 0;
	uint8_t leftoverBits = 0;
	uint8_t numLeftoverBits = 0;
	
	for (NSString * character in inputCharacters)
	{
		NSNumber * characterSetIndexObj = lookup[character];
		if (characterSetIndexObj == nil)
		{
			continue; // Ignore unknown chars
		}
		
		uint32_t originalIndex = characterSetIndexObj.unsignedIntValue;
		
		if (numLeftoverBits > 0)
		{
			originalIndex <<= numLeftoverBits;
			originalIndex |= leftoverBits;
		}
		
		NSUInteger numBitsInPlay = numBitsCompressedIntoOneEmoji + numLeftoverBits;
		while (numBitsInPlay >= ECBitsPerByte)
		{
			scratchSpace[scratchIndex++] = originalIndex & 0xFF;
			originalIndex >>= ECBitsPerByte;
			numBitsInPlay -= ECBitsPerByte;
		}
		
		numLeftoverBits = numBitsInPlay;
		leftoverBits = originalIndex;
	};
	
	fprintf(stdout, "%s", scratchSpace);
	
	free(scratchSpace);
}