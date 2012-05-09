//
//  SGDetailViewController.m
//  iLibrary
//
//  Created by Simon Grätzer on 20.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SGDetailViewController.h"

@implementation SGDetailViewController

@synthesize document = _document;
@synthesize textView = _textView;
@synthesize documentPopoverController = _documentPopoverController;
@synthesize keyboardHeight = _keyboardHeight;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_document) {
        [_document closeWithCompletionHandler:NULL];
    }
    [_document release];
    [_textView release];
    [_documentPopoverController release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.textView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillUpdate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillUpdate:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillUpdate:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textView flashScrollIndicators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.document = nil;
    self.keyboardHeight = 0.0;
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Documents", @"Documents");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.documentPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.documentPopoverController = nil;
}

#pragma mark - Keyboard

- (void)setKeyboardHeight:(CGFloat)value
{
    _keyboardHeight = value;
    
    CGFloat parentHeight = self.view.bounds.size.height;
    CGRect frame = self.textView.frame;
    frame.size.height = parentHeight - _keyboardHeight;
    self.textView.frame = frame;
}

- (void)keyboardWillUpdate:(NSNotification *)notification
{
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGRect endFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    endFrame = [self.view convertRect:[[self.view window] convertRect:endFrame fromWindow:nil] fromView:nil];
    endFrame = CGRectIntersection(endFrame, self.view.bounds);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    self.keyboardHeight = endFrame.size.height;
    [UIView commitAnimations];
}

#pragma mark - Document

- (void)documentContentsDidUpdate:(SGDocument *)document
{
    self.textView.text = self.document.contents;
}

- (void)documentStateChanged:(NSNotification *)notification
{
    UIDocumentState documentState = self.document.documentState;
    self.textView.editable = ((documentState & UIDocumentStateEditingDisabled) != UIDocumentStateEditingDisabled);
    if (documentState & UIDocumentStateInConflict) {
        // This application uses a basic newest version wins conflict resolution strategy
        NSURL *documentURL = self.document.fileURL;
        NSArray *conflictVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:documentURL];
        for (NSFileVersion *fileVersion in conflictVersions) {
            fileVersion.resolved = YES;
        }
        [NSFileVersion removeOtherVersionsOfItemAtURL:documentURL error:nil];
    }
    if (documentState & UIDocumentStateSavingError) {
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 21.0)] autorelease];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithHue:0.0 saturation:1.0 brightness:0.75 alpha:1.0];
        label.text = NSLocalizedString(@"Unsaved", @"Unsaved");
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:label] autorelease];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)setDocument:(SGDocument *)value
{
    if (_document != value) {
        if (_document) {
            _document.delegate = nil;
            _document.undoManager = nil;
            [_document closeWithCompletionHandler:NULL];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDocumentStateChangedNotification object:_document];
        }
        _document = value;
        self.title = [[_document.fileURL lastPathComponent] stringByDeletingPathExtension];
        self.navigationItem.rightBarButtonItem = nil;
        [self.textView resignFirstResponder];
        self.textView.hidden = YES;
        [self.textView.undoManager removeAllActions];
        if (_document) {
            [self.documentPopoverController dismissPopoverAnimated:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentStateChanged:) name:UIDocumentStateChangedNotification object:_document];
            _document.delegate = self;
            [_document openWithCompletionHandler:^(BOOL success) {
                if (_document == value) {
                    [self documentContentsDidUpdate:_document];
                    _document.undoManager = self.textView.undoManager;
                    self.textView.hidden = NO;
                }
            }];
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.document.contents = self.textView.text;
}

@end
