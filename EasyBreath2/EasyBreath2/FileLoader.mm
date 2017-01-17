//
//  FileLoader.m
//  EasyBreath2
//
//  Created by Mark Zolotas on 12/03/2016.
//  Copyright © 2016 Charitos Charitou. All rights reserved.
//

#import <Foundation/Foundation.h>

const char* read_training_file() {
    NSString* train_string = [[NSBundle mainBundle] pathForResource:@"stress_training_data" ofType:@"csv"];
    
    const char* train_path = [train_string fileSystemRepresentation];
    
    return train_path;
}

const char* read_test_file() {
    NSString* test_string = [[NSBundle mainBundle] pathForResource:@"stress_test_data" ofType:@"csv"];
    
    const char* test_path = [test_string fileSystemRepresentation];
    
    return test_path;
}

const char* read_svm_file() {
    NSString* svm_string = [[NSBundle mainBundle] pathForResource:@"svmClassifier" ofType:@"xml"];
    
    const char* svm_path = [svm_string fileSystemRepresentation];
    
    return svm_path;
}

const char* read_dt_file() {
    NSString* dt_string = [[NSBundle mainBundle] pathForResource:@"dtClassifier" ofType:@"xml"];
    
    const char* dt_path = [dt_string fileSystemRepresentation];
    
    return dt_path;
}