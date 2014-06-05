/* vim: set ai noet ts=4 sw=4 tw=115: */
//
// Copyright (c) 2014 Nikolay Zapolnov (zapolnov@gmail.com).
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
#import "NZAirPlayViewController.h"

@implementation NZAirPlayViewController

@synthesize externalScreen;
@synthesize externalWindow;

-(void)viewDidLoad
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidChange)
		name:UIScreenDidConnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidChange)
		name:UIScreenDidDisconnectNotification object:nil];
	[self screenDidChange];
}

-(void)dealloc
{
	[primaryView release];
	primaryView = nil;
	[secondaryView release];
	secondaryView = nil;
	[externalScreen release];
	externalScreen = nil;
	[externalWindow release];
	externalWindow = nil;
	[super dealloc];
}

-(UIView *)primaryView
{
	[self ensureHasPrimaryView];
	return primaryView;
}

-(void)setPrimaryView:(UIView *)view
{
	[primaryView release];
	primaryView = [view retain];
	[self updateViewHierarchy];
}

-(UIView *)secondaryView
{
	[self ensureHasSecondaryView];
	return secondaryView;
}

-(void)setSecondaryView:(UIView *)view
{
	[secondaryView release];
	secondaryView = [view retain];
	[self updateViewHierarchy];
}

-(void)ensureHasPrimaryView
{
	if (!primaryView)
	{
		primaryView = [self newPrimaryView];
		[self updateViewHierarchy];
	}
}

-(void)ensureHasSecondaryView
{
	if (!secondaryView)
	{
		secondaryView = [self newSecondaryView];
		[self updateViewHierarchy];
	}
}

-(void)viewWillLayoutSubviews
{
	if (!externalScreen)
		primaryView.frame = self.view.bounds;
	else
	{
		primaryView.frame = externalScreen.bounds;
		secondaryView.frame = self.view.bounds;
	}
}

-(void)screenDidChange
{
	[externalWindow release];
	externalWindow = nil;
	[externalScreen release];
	externalScreen = nil;

	NSArray * screens = [UIScreen screens];
	NSUInteger screenCount = [screens count];
	NSLog(@"Screen count: %d", screenCount);

	if (screenCount > 1)
	{
		externalScreen = [[screens objectAtIndex:1] retain];

		NSArray * availableModes = [externalScreen availableModes];
		externalScreen.currentMode = [availableModes objectAtIndex:[self selectVideoMode:availableModes]];
		externalScreen.overscanCompensation = UIScreenOverscanCompensationInsetApplicationFrame;

		externalWindow = [[UIWindow alloc] initWithFrame:externalScreen.bounds];
		externalWindow.screen = externalScreen;
		[externalWindow makeKeyAndVisible];
	}

	[self updateViewHierarchy];

	if (screenCount < 2)
		[self screenDidDisconnect];
	else
		[self screenDidConnect];
}

-(void)updateViewHierarchy
{
	[primaryView removeFromSuperview];
	[secondaryView removeFromSuperview];

	[self ensureHasPrimaryView];

	if (!externalScreen)
		[self.view addSubview:self.primaryView];
	else
	{
		[self ensureHasSecondaryView];
		[externalWindow addSubview:self.primaryView];
		[self.view addSubview:self.secondaryView];
	}

	[self viewWillLayoutSubviews];
}

-(NSInteger)selectVideoMode:(NSArray *)availableModes
{
	return [availableModes count] - 1;
}

-(UIView *)newPrimaryView
{
	UIView * view = [[UIView alloc] initWithFrame:CGRectZero];
	view.backgroundColor = [UIColor whiteColor];
	return view;
}

-(UIView *)newSecondaryView
{
	UILabel * view = [[UILabel alloc] initWithFrame:CGRectZero];
	view.textAlignment = NSTextAlignmentCenter;
	view.textColor = [UIColor whiteColor];
	view.backgroundColor = [UIColor blackColor];
	view.numberOfLines = 2;
	view.text = @"Content is being displayed\non the AirPlay device.";
	return view;
}

-(void)screenDidConnect
{
}

-(void)screenDidDisconnect
{
}

@end
