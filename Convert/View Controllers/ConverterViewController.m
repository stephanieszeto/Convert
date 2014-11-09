//
//  ConverterViewController.m
//  Convert
//
//  Created by Stephanie Szeto on 11/7/14.
//  Copyright (c) 2014 stephanie. All rights reserved.
//

#import "ConverterViewController.h"

@interface ConverterViewController ()

@property (nonatomic, strong) NSDictionary *rates;
@property (nonatomic, strong) NSArray *pickerData;
@property (nonatomic, strong) NSArray *ratesArray;
@property (assign) BOOL dollarsLastChanged;

@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UITextField *dollarValue;
@property (weak, nonatomic) IBOutlet UITextField *currencyValue;
@property (weak, nonatomic) IBOutlet UIPickerView *currencyPicker;

@property (assign) BOOL dollarMOn;
@property (assign) BOOL dollarBOn;
@property (assign) BOOL dollarTOn;
@property (assign) BOOL currencyMOn;
@property (assign) BOOL currencyBOn;
@property (assign) BOOL currencyTOn;

- (IBAction)onDollarM:(id)sender;
- (IBAction)onDollarB:(id)sender;
- (IBAction)onDollarT:(id)sender;
- (IBAction)onCurrencyM:(id)sender;
- (IBAction)onCurrencyB:(id)sender;
- (IBAction)onCurrencyT:(id)sender;

@end

@implementation ConverterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // initialize labels
    self.currencyLabel.text = @"KRW";
    self.currencyValue.font = [UIFont systemFontOfSize:40];
    self.dollarValue.font = [UIFont systemFontOfSize:40];
    
    // initialize currency rate array
    self.ratesArray = @[@"KRW", @"JPY", @"CNY", @"EUR", @"GBP"];
    
    // initialize currency picker values
    self.pickerData = @[@"korean won", @"japanese yen", @"renmenbi", @"euro", @"uk pound"];
    self.currencyPicker.dataSource = self;
    self.currencyPicker.delegate = self;
    
    // set up targets for text fields
    [self.dollarValue addTarget:self action:@selector(dollarValueDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.currencyValue addTarget:self action:@selector(currencyValueDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    // set up general gesture recognizer
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onGeneralTap:)]];
    
    [self loadRates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UIPicker delegate methods

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return (int) 1;
}

- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return (int) self.pickerData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.dollarsLastChanged) {
        [self dollarValueDidChange:self];
    } else {
        [self currencyValueDidChange:self];
    }
    
    self.currencyLabel.text = self.ratesArray[[self.currencyPicker selectedRowInComponent:0]];
}

# pragma mark - Private methods

- (void)dollarValueDidChange:(id)sender {
    float dollars = [self.dollarValue.text floatValue];
    
    // find relevant exchange rate
    NSInteger row = [self.currencyPicker selectedRowInComponent:0];
    float exchangeRate = [self.rates[self.ratesArray[row]] floatValue];
    NSLog(@"exchange rate: %f", exchangeRate);
    
    // perform calculation
    float currencyFloat = dollars * exchangeRate;
    self.currencyValue.text = [NSString stringWithFormat:@"%0.2f", currencyFloat];
    
    self.dollarsLastChanged = YES;
}

- (void)currencyValueDidChange:(id)sender {
    float currencyFloat = [self.currencyValue.text floatValue];
    
    // find relevant exchange rate
    NSInteger row = [self.currencyPicker selectedRowInComponent:0];
    float exchangeRate = [self.rates[self.ratesArray[row]] floatValue];
    NSLog(@"exchange rate: %f", exchangeRate);
    
    // perform calculation
    float dollars = currencyFloat / exchangeRate;
    self.dollarValue.text = [NSString stringWithFormat:@"%0.2f", dollars];
    
    self.dollarsLastChanged = NO;
}

- (void)onGeneralTap:(id)sender {
    [self.view endEditing:YES];
}

- (void)loadRates {
    NSString *url = @"http://openexchangerates.org/api/latest.json?app_id=91a77ae4d9884e8f90540e3163563297";
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.rates = [json objectForKey:@"rates"];
        NSLog(@"response: %@", json);
    }];
}

- (void)multiplyOut:(UITextField *)textField factor:(float)factor {
    float value = [textField.text floatValue];
    float newValue = value * factor;
    textField.text = [NSString stringWithFormat:@"%0.2f", newValue];
}

- (void)divideBy:(UITextField *)textField factor:(float)factor {
    float value = [textField.text floatValue];
    float newValue = value / factor;
    textField.text = [NSString stringWithFormat:@"%0.2f", newValue];
}

# pragma mark - UIButton action methods

- (IBAction)onDollarM:(id)sender {
    if (!self.dollarMOn) {
        [self multiplyOut:self.dollarValue factor:1000000];
    } else {
        [self divideBy:self.dollarValue factor:1000000];
    }
    
    self.dollarMOn = !self.dollarMOn;
    self.dollarsLastChanged = YES;
}

- (IBAction)onDollarB:(id)sender {
    if (!self.dollarBOn) {
        [self multiplyOut:self.dollarValue factor:1000000000];
    } else {
        [self divideBy:self.dollarValue factor:1000000000];
    }
    
    self.dollarBOn = !self.dollarBOn;
    self.dollarsLastChanged = YES;
}

- (IBAction)onDollarT:(id)sender {
    if (!self.dollarTOn) {
        [self multiplyOut:self.dollarValue factor:1000000000000];
    } else {
        [self divideBy:self.dollarValue factor:1000000000000];
    }
    
    self.dollarTOn = !self.dollarTOn;
    self.dollarsLastChanged = YES;
}

- (IBAction)onCurrencyM:(id)sender {
    if (!self.currencyMOn) {
        [self multiplyOut:self.currencyValue factor:1000000];
    } else {
        [self divideBy:self.currencyValue factor:1000000];
    }
    
    self.currencyMOn = !self.currencyMOn;
    self.dollarsLastChanged = NO;
}

- (IBAction)onCurrencyB:(id)sender {
    if (!self.currencyBOn) {
        [self multiplyOut:self.currencyValue factor:1000000000];
    } else {
        [self divideBy:self.currencyValue factor:1000000000];
    }
    
    self.currencyBOn = !self.currencyBOn;
    self.dollarsLastChanged = NO;
}

- (IBAction)onCurrencyT:(id)sender {
    if (!self.currencyTOn) {
        [self multiplyOut:self.currencyValue factor:1000000000000];
    } else {
        [self divideBy:self.currencyValue factor:1000000000000];
    }
    
    self.currencyTOn = !self.currencyTOn;
    self.dollarsLastChanged = NO;
}
@end
