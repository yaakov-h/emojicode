#import <Foundation/Foundation.h>
#import "emojicode.h"

void RunEncode(NSArray * characters)
{
	NSUInteger numBitsWeCanCompressIntoOneEmoji = (int)log2(characters.count);
	NSUInteger numBitsRequiredToRead = roundup(numBitsWeCanCompressIntoOneEmoji, ECBitsPerByte);
	NSUInteger numBytesRequiredToRead = numBitsRequiredToRead / ECBitsPerByte;
	NSUInteger emojiBytesLength = numBytesRequiredToRead + 1;
	
	size_t numBytesRead;
	uint8_t * emojiBytes = (uint8_t *)malloc(emojiBytesLength);
	uint8_t leftoverBits = 0;
	uint8_t numLeftoverBits = 0;
	
	do
	{
		memset(emojiBytes, 0, emojiBytesLength);
		numBytesRead = read(STDIN_FILENO, emojiBytes, numBytesRequiredToRead);
		if (numBytesRead == 0)
		{
			if (numLeftoverBits > 0)
			{
				NSString * emojiChar = characters[leftoverBits];
				fprintf(stdout, "%s", emojiChar.UTF8String);
			}
			
			break;
		}
		
		if (numLeftoverBits > 0)
		{
			NSUInteger numBitsToHandDown = (ECBitsPerByte - (numLeftoverBits % 8));
			NSUInteger handMeDownMask = MakeBinaryMask(numBitsToHandDown);
			
			if (numLeftoverBits == ECBitsPerByte)
			{
				for (NSUInteger i = emojiBytesLength - 1; i > 0; i--)
				{
					emojiBytes[i] = emojiBytes[i - 1];
				}
				emojiBytes[0] = leftoverBits;
			}
			else
			{
				uint8_t mergeStartPoint = numLeftoverBits / ECBitsPerByte;
				
				for (NSUInteger i = emojiBytesLength - 1; i > mergeStartPoint; i--)
				{
					emojiBytes[i] = ((emojiBytes[i-1] & ~handMeDownMask) >> numBitsToHandDown) | emojiBytes[i];
					emojiBytes[i-1] <<= ECBitsPerByte - numBitsToHandDown;
				}
				
				NSUInteger leftoverBitsForMerging = leftoverBits;
				emojiBytes[mergeStartPoint] |= leftoverBitsForMerging & 0xFF;
				leftoverBitsForMerging >>= ECBitsPerByte;
				
				for (NSInteger i = mergeStartPoint - 1; i >= 0; i--)
				{
					uint8_t leftoverBitsToMerge = (leftoverBitsForMerging >> ECBitsPerByte) & 0xFF;
					leftoverBitsForMerging >>= ECBitsPerByte;
					
					emojiBytes[i] = leftoverBitsToMerge;
				}
			};
		}
		
		NSUInteger emojiIndex = 0;
		for (NSUInteger i = 0; i < emojiBytesLength; i++)
		{
			emojiIndex = emojiIndex | (emojiBytes[i] << (ECBitsPerByte * i));
		}
		
		NSUInteger numBitsInBuffer = (numBytesRead * ECBitsPerByte) + numLeftoverBits;
		NSUInteger numEmojiToPrint = numBitsInBuffer / numBitsWeCanCompressIntoOneEmoji;
		
		for (NSUInteger i = 0; i < numEmojiToPrint; i++)
		{
			NSUInteger actualIndex = emojiIndex & MakeBinaryMask(numBitsWeCanCompressIntoOneEmoji);
			emojiIndex >>= numBitsWeCanCompressIntoOneEmoji;
			
			NSString * emojiChar = characters[actualIndex];
			// printf("%u\n\n", (unsigned)actualIndex);
			printf("%s", [emojiChar UTF8String]);
		}
		
		leftoverBits = emojiIndex;
		
		NSUInteger numBitsPrinted = (numEmojiToPrint * numBitsWeCanCompressIntoOneEmoji);
		
		numLeftoverBits = numBitsInBuffer - numBitsPrinted;
	} while (true);
	
	free(emojiBytes);
}
