//
//  ViewController.m
//  SampleAppObjC
//
//  Created by Anurag Ajwani on 22/11/2017.
//  Copyright © 2017 onfido. All rights reserved.
//

#import "ViewController.h"
#import <Onfido/Onfido-Swift.h>

@implementation ViewController

- (IBAction)verifyUser:(id)sender {
    
    // TODO Call your backend to get `sdkToken` https://github.com/onfido/onfido-ios-sdk#31-sdk-tokens
    NSString * sdkToken = @"SDK_TOKEN";
    
    ONFlowConfigBuilder *configBuilder = [ONFlowConfig builder];
    [configBuilder withSdkToken:sdkToken];
    [configBuilder withWelcomeStep];
    [configBuilder withDocumentStep];
    
    Builder *faceStepVariantBuilder = [ONFaceStepVariantConfig builder];
    [faceStepVariantBuilder withPhotoCaptureWithConfig: NULL];
    NSError *faceVariantStepConfigError = NULL;
    ONFaceStepVariantConfig *faceStepVariant = [faceStepVariantBuilder buildAndReturnError: &faceVariantStepConfigError];
    
    if (faceVariantStepConfigError != NULL) {
        [self showError:[[faceVariantStepConfigError userInfo] valueForKey:@"message"]];
        return;
    }
    
    [configBuilder withFaceStepOfVariant: faceStepVariant];
    NSError *configError = NULL;
    ONFlowConfig *config = [configBuilder buildAndReturnError:&configError];
    if (configError != NULL) {
        [self showError:[[configError userInfo] valueForKey:@"message"]];
        return;
    }
    
    ONFlow *flow = [[ONFlow alloc] initWithFlowConfiguration:config];
    
    
    NSError *runError = NULL;
    UIViewController *flowVC = [flow runAndReturnError:&runError];
    flowVC.modalPresentationStyle = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? UIModalPresentationFormSheet : UIModalPresentationFullScreen; // to present modally on iPads

    if (runError == NULL) {
        [self presentViewController:flowVC animated:YES completion:nil];
    } else {
        [self showError:[[runError userInfo] valueForKey:@"message"]];
    }
    
    [flow withResponseHandler:^(ONFlowResponse * _Nonnull response) {
        
        if (response.error) {
            [self showError:[[response.error userInfo] valueForKey:@"message"]];
        } else if (response.userCanceled) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Canceled" message:@"Canceled by user" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        } else if (response.results.count > 0) {
            // SDK flow has been completed successfully. You may want to create a check in your backend at this point.
            // Follow https://github.com/onfido/onfido-ios-sdk#2-creating-a-check to understand how to create a check
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"SDK flow has been completed successfully" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}


- (void)showError: (NSString *) message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"Onfido SDK errored %@", message] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
