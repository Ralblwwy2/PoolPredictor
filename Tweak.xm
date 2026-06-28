#import <UIKit/UIKit.h>

#define kConsecutiveNoBreaks @"Mod_ConsecutiveNoBreaks"

float getBreakPredictionPercentage() {
    float baseChance = 50.0f; 
    NSInteger consecutiveNoBreaks = [[NSUserDefaults standardUserDefaults] integerForKey:kConsecutiveNoBreaks];
    
    if (consecutiveNoBreaks > 0) {
        baseChance += (consecutiveNoBreaks * 15.0f); 
    } else {
        baseChance = 35.0f; 
    }
    
    if (baseChance > 95.0f) baseChance = 95.0f;
    if (baseChance < 5.0f) baseChance = 5.0f;
    
    return baseChance;
}

%hook GameController 
- (void)matchStartedWithData:(id)matchData {
    %orig;
    BOOL isLocalUserTurn = [self isMyTurn]; 
    NSInteger consecutiveNoBreaks = [[NSUserDefaults standardUserDefaults] integerForKey:kConsecutiveNoBreaks];
    
    if (isLocalUserTurn) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kConsecutiveNoBreaks];
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:(consecutiveNoBreaks + 1) forKey:kConsecutiveNoBreaks];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
%end

%hook TableSelectionView 
- (void)layoutSubviews {
    %orig;
    UILabel *percentageLabel = [self viewWithTag:888];
    if (!percentageLabel) {
        percentageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height + 4, self.bounds.size.width, 18)];
        percentageLabel.tag = 888;
        percentageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0f];
        percentageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:percentageLabel];
    }
    
    float currentChance = getBreakPredictionPercentage();
    percentageLabel.text = [NSString stringWithFormat:@"Break Chance: %.0f%%", currentChance];
    
    if (currentChance >= 70.0f) {
        percentageLabel.textColor = [UIColor greenColor];
    } else if (currentChance <= 35.0f) {
        percentageLabel.textColor = [UIColor redColor];
    } else {
        percentageLabel.textColor = [UIColor whiteColor];
    }
}
%end
