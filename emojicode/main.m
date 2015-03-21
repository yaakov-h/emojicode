#include <Foundation/Foundation.h>
#include "emojicode.h"

const NSUInteger ECBitsPerByte = 8;

typedef NS_ENUM(NSUInteger, ECApplicationOperationMode)
{
	ECApplicationOperationModeNone = 0,
	ECApplicationOperationModeEncodeDataToCharacters,
	ECApplicationOperationModeDecodeCharactersToData
};

struct ECApplicationArguments
{
	ECApplicationOperationMode mode;
};

void PrintUsage(const char * executableName)
{
	const char * executableNameLastSlash = strrchr(executableName, '/');
	if (executableNameLastSlash != NULL)
	{
		executableName = executableNameLastSlash + 1;
	}
	
	fprintf(stdout, "Usage: %s [-e | -d]\n", executableName);
}

BOOL ParseArguments(int argc, const char * argv[], struct ECApplicationArguments * arguments)
{
	if (argc != 2)
	{
		return false;
	}
	
	const char * modeFlag = argv[1];
	
	if (strcmp(modeFlag, "-e") == 0)
	{
		arguments->mode = ECApplicationOperationModeEncodeDataToCharacters;
	}
	else if (strcmp(modeFlag, "-d") == 0)
	{
		arguments->mode = ECApplicationOperationModeDecodeCharactersToData;
	}
	else
	{
		return NO;
	}
	
	return YES;
}

int main(int argc, const char * argv[])
{
	struct ECApplicationArguments arguments;
	if (!ParseArguments(argc, argv, &arguments))
	{
		PrintUsage(argv[0]);
		return -1;
	}
	
	NSArray * charactersForEncoding = GetCharacterSet();
	
	NSUInteger numBitsWeCanCompressIntoOneEmoji = (int)log2(charactersForEncoding.count);
	fprintf(stderr, ">> Using %u bits per emoji, %u characters out of a set of %u.\n\n", (unsigned)numBitsWeCanCompressIntoOneEmoji, (unsigned)(1 << numBitsWeCanCompressIntoOneEmoji), (unsigned)charactersForEncoding.count);
	
	switch (arguments.mode)
	{
		case ECApplicationOperationModeEncodeDataToCharacters:
			RunEncode(charactersForEncoding);
			break;
			
		case ECApplicationOperationModeDecodeCharactersToData:
			RunDecode(charactersForEncoding);
			break;
			
		default:
			break;
	}
	
	printf("\n");
	
    return 0;
}
