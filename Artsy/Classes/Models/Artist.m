#import "ARNetworkConstants.h"

@interface Artist() {
    BOOL _isFollowed;
}
@property (nonatomic, copy, readonly) NSString *urlFormatString;
@end

@implementation Artist

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"artistID" : @"id",
        @"name" : @"name",
        @"years" : @"years",
        @"birthday" : @"birthday",
        @"nationality" : @"nationality",
        @"blurb": @"blurb",
        @"publishedArtworksCount": @"published_artworks_count",
        @"forSaleArtworksCount": @"forsale_artworks_count",
        @"urlFormatString": @"image_url"
    };
}

- (NSURL *)largeImageURL
{
    return [NSURL URLWithString:[self.urlFormatString stringByReplacingOccurrencesOfString:@":version" withString:@"square"]];
}

// the smallest is thumb on an artist

- (NSURL *)smallImageURL
{
    return [NSURL URLWithString:[self.urlFormatString stringByReplacingOccurrencesOfString:@":version" withString:@"square"]];
}

- (NSString *)baseImageURL
{
    return self.urlFormatString;
}

- (instancetype)initWithArtistID:(NSString *)artistID
{
    self = [super init];
    if (!self) { return nil; }

    _artistID = artistID;

    return self;
}

- (void)setFollowed:(BOOL)isFollowed
{
    _isFollowed = isFollowed;
}

- (BOOL)isFollowed
{
    return _isFollowed;
}

- (void)followWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [self setFollowState:YES success:success failure:failure];
}

- (void)unfollowWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [self setFollowState:NO success:success failure:failure];
}

- (void)setFollowState:(BOOL)state success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    @weakify(self);
    [ArtsyAPI setFavoriteStatus:state forArtist:self success:^(id response) {
        @strongify(self);
        self.followed = state;
        if (success) {
            success(response);
        }
    } failure:^(NSError *error) {
        @strongify(self);
        self.followed = !state;
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getFollowState:(void (^)(ARHeartStatus status))success failure:(void (^)(NSError *error))failure
{
    if ([User isTrialUser]) {
        success(ARHeartStatusNo);
        return;
    }

    @weakify(self);
    [ArtsyAPI checkFavoriteStatusForArtist:self success:^(BOOL result) {
        @strongify(self);
        self.followed = result;
        success(result ? ARHeartStatusYes : ARHeartStatusNo);
    } failure:failure];
}

- (void)getArtworksAtPage:(NSInteger)page andParams:(NSDictionary *)params success:(void (^)(NSArray *artworks))success {
    [ArtsyAPI getArtistArtworks:self andPage:page withParams:params success:^(NSArray *artworks) {
        success(artworks);
    } failure:^(NSError *error) {
        success(@[]);
    }];
}

- (NSString *)publicURL {
    NSString *path = [NSString stringWithFormat:ARArtistInformationURLFormat, self.artistID];
    NSURL *url = [ARSwitchBoard.sharedInstance resolveRelativeUrl:path];
    return [url absoluteString];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[Artist class]]) {
        return NO;
    }
    Artist *other = (Artist *)object;
    return [self.artistID isEqualToString:other.artistID];

}

- (NSUInteger)hash
{
    return self.artistID.hash;
}

- (AFJSONRequestOperation *)getRelatedPosts:(void (^)(NSArray *posts))success
{
    return [ArtsyAPI getRelatedPostsForArtist:self
        success:success
        failure: ^(NSError *error) {
           success(@[]);
    }];
}

- (AFJSONRequestOperation *)getRelatedArtists:(void (^)(NSArray *artists))success
{
    return [ArtsyAPI getRelatedArtistsForArtist:self
        success:success
        failure: ^(NSError *error) {
            success(@[]);
    }];
}

#pragma mark ShareableObject
- (NSString *)publicArtsyPath
{
    return [NSString stringWithFormat:@"/artist/%@", self.artistID];
}

@end
