#import "SearchResult.h"
#import "ARRouter.h"

static NSDictionary *classMap;

@implementation SearchResult

+ (BOOL)searchResultIsSupported:(NSDictionary *)dict
{
    return [[classMap allKeys] containsObject:dict[@"model"]];
}

+ (NSInteger)version
{
    return 1;
}

+ (void)initialize
{
    classMap = @{
        @"artwork": [Artwork class],
        @"gene": [Gene class],
        @"artist": [Artist class],
        @"profile" : [Profile class],
        @"feature" : [SiteFeature class],

        // This is _NOT_ from the API, but comes from ARFairSearchVC
        @"partnershow" : [PartnerShow class]

    };
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"modelID" : @"id",
        @"displayText" : @"display",
        @"modelString" : @"model",
        @"label" : @"label",
        @"searchDetail" : @"search_detail",
        @"isPublished" : @"published",
    };
}

- (Class)model
{
    return classMap[self.modelString];
}

- (NSURLRequest *)imageRequest
{
    return [ARRouter directImageRequestForModel:self.model andSlug:self.modelID];
}

- (BOOL)isEqual:(id)object
{
    if([object isKindOfClass:self.class]){
        return [self.model isEqual:[object model]] && [self.modelID isEqualToString:[object modelID]];
    }

    return [super isEqual:object];
}

- (NSUInteger)hash
{
    return NSStringWithFormat(@"%@:%@", self.model, self.modelID).hash;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.modelID forKey:@"id"];
    [encoder encodeObject:self.displayText forKey:@"display"];
    [encoder encodeObject:self.modelString forKey:@"model"];
    [encoder encodeObject:self.label forKey:@"label"];
    [encoder encodeObject:self.searchDetail forKey:@"search_detail"];
    [encoder encodeObject:self.isPublished forKey:@"published"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self) { return nil; }

    _modelID = [decoder decodeObjectForKey:@"id"];
    _displayText = [decoder decodeObjectForKey:@"display"];
    _modelString = [decoder decodeObjectForKey:@"model"];
    _label = [decoder decodeObjectForKey:@"label"];
    _searchDetail = [decoder decodeObjectForKey:@"search_detail"];
    _isPublished = [decoder decodeObjectForKey:@"published"];

    return self;
}

@end
