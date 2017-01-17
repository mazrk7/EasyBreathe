//
//  opencv_funcs.cpp
//  EasyBreath2
//
//  Created by Mark Zolotas on 27/02/2016.
//  Copyright © 2016 Charitos Charitou. All rights reserved.
//

#include <stdio.h>
#include "opencv_funcs.h" // For our functions definitions
#include "CvMat.hpp" // For recover() & makePtr() functions
#include <opencv2/core.hpp> // OpenCV core
#include <opencv2/ml.hpp> // OpenCV machine learning
#include "FileLoader.mm"

// MARK: TRAINING

cv::Ptr<cv::ml::TrainData> setupTrainingData()
{
    std::string filePath = read_training_file();
    
    cv::Ptr<cv::ml::TrainData> stressTrainingTable = cv::ml::TrainData::loadFromCSV(filePath, 1);
    
    if (stressTrainingTable.empty())
        std::cout << "Stress training data could not be loaded..." << std::endl;
    
    return stressTrainingTable;
}

float trainSVM()
{
    // TRAINING
    std::string filePath = read_svm_file();
    cv::Ptr<cv::ml::TrainData> trainingData = setupTrainingData();
    
    // Set up SVM's parameters:
    // Type --> C_SVC
    // Kernel --> Linear
    cv::Ptr<cv::ml::SVM> svm = cv::ml::SVM::create();
    svm->setType(cv::ml::SVM::C_SVC);
    svm->setKernel(cv::ml::SVM::INTER);
    
    int kFold = 10;
    bool balanced = true; // Balanced 2-class decision tree
    
    // trainAuto to find best parameters supposedly
    bool trained = svm->trainAuto(trainingData, kFold,
                                  cv::ml::SVM::getDefaultGrid(cv::ml::SVM::C),
                                  cv::ml::SVM::getDefaultGrid(cv::ml::SVM::GAMMA),
                                  cv::ml::SVM::getDefaultGrid(cv::ml::SVM::P),
                                  cv::ml::SVM::getDefaultGrid(cv::ml::SVM::NU),
                                  cv::ml::SVM::getDefaultGrid(cv::ml::SVM::COEF),
                                  cv::ml::SVM::getDefaultGrid(cv::ml::SVM::DEGREE),
                                  balanced);
    
    std::string testFilePath = read_test_file();
    cv::Ptr<cv::ml::TrainData> testData = cv::ml::TrainData::loadFromCSV(testFilePath, 1);
    
    cv::Mat testSamples = testData->getTrainSamples();
    cv::Mat testLabels = testData->getTrainResponses();
    
    cv::Mat confusion = cv::Mat::zeros(2, 2, CV_32F);
    const int TP = 0;
    const int FN = 1;
    const int FP = 2;
    const int TN = 3;
    
    for (int i=0; i<testSamples.rows; i++) {
        cv::Mat sample = testSamples.row(i);
        
        float label = testLabels.at<float>(i, 0);
        
        float predicted = svm->predict(sample);
        
        if(label == 1.0f && predicted == 1.0f)
            confusion.at<float>(TP)++;
        else if(label == 0.f && predicted == 0.f)
            confusion.at<float>(TN)++;
        else
            confusion.at<float>(label == 0.f? FP : FN)++;
    }
    
    float accuracy = ((confusion.at<float>(TP)+confusion.at<float>(TN))/testSamples.rows) * 100;
    float precision = (confusion.at<float>(TP)/(confusion.at<float>(TP)+confusion.at<float>(FP))) * 100;
    
    std::cout << "Accuracy_{SVM} = " << accuracy << "%" << std::endl;
    std::cout << "Precision_{SVM} = " << precision << "%" << std::endl;
    
    // TESTING
    if (trained)
        svm->save(filePath);
    else
    {
        std::cout << "SVM model not properly trained..." << std::endl;
        accuracy = -1.0f;
    }
    
    return accuracy;
}

float trainDT()
{
    // TRAINING
    std::string filePath = read_dt_file();
    cv::Ptr<cv::ml::TrainData> trainingData = setupTrainingData();

    // Set up Decision Tree's parameters:
    cv::Ptr<cv::ml::DTrees> dt = cv::ml::DTrees::create();
    dt->setMaxDepth(8);
    dt->setMinSampleCount(10);
    dt->setRegressionAccuracy(0); // N/A here
    dt->setUseSurrogates(false); // No missing data, hopefully
    dt->setCVFolds(0);
    dt->setUse1SERule(true); // Smaller tree
    dt->setTruncatePrunedTree(true); // Throw away pruned tree
    
    bool trained = dt->train(trainingData);
    
    // TESTING
    std::string testFilePath = read_test_file();
    cv::Ptr<cv::ml::TrainData> testData = cv::ml::TrainData::loadFromCSV(testFilePath, 1);
    
    cv::Mat testSamples = testData->getTrainSamples();
    cv::Mat testLabels = testData->getTrainResponses();
    
    cv::Mat confusion = cv::Mat::zeros(2, 2, CV_32F);
    const int TP = 0;
    const int FN = 1;
    const int FP = 2;
    const int TN = 3;
    
    for (int i=0; i<testSamples.rows; i++) {
        cv::Mat sample = testSamples.row(i);
        
        float label = testLabels.at<float>(i, 0);
        
        float predicted = dt->predict(sample, cv::noArray(), cv::ml::DTrees::PREDICT_AUTO);
        
        if(label == 1.0f && predicted == 1.0f)
            confusion.at<float>(TP)++;
        else if(label == 0.f && predicted == 0.f)
            confusion.at<float>(TN)++;
        else
            confusion.at<float>(label == 0.f? FP : FN)++;
    }
        
    float accuracy = ((confusion.at<float>(TP)+confusion.at<float>(TN))/testSamples.rows) * 100;
    float precision = (confusion.at<float>(TP)/(confusion.at<float>(TP)+confusion.at<float>(FP))) * 100;

    std::cout << "Accuracy_{TREE} = " << accuracy << "%" << std::endl;
    std::cout << "Precision_{TREE} = " << precision << "%" << std::endl;

    if (trained)
        dt->save(filePath);
    else
    {
        std::cout << "DT model not properly trained..." << std::endl;
        accuracy = -1.0f;
    }
    
    return accuracy;
}

// MARK: FEATURE EXTRACTION

float computeActivity(cv::Mat x_axis, cv::Mat y_axis, cv::Mat z_axis, int n)
{
    float activity = 0.0f;
    
    for(int i=0; i<(n-1); i++)
    {
        float diffX = x_axis.at<float>(i+1, 0) - x_axis.at<float>(i, 0);
        float diffY = y_axis.at<float>(i+1, 0) - y_axis.at<float>(i, 0);
        float diffZ = z_axis.at<float>(i+1, 0) - z_axis.at<float>(i, 0);
        
        activity += sqrtf(diffX*diffX + diffY*diffY + diffZ*diffZ);
    }
    
    return activity;
}

float computeRMSSD(cv::Mat rrIntervals,  int n)
{
    float sum_diff = 0.0f;
    
    for(int i=0; i<(n-1); i++)
    {
        float diff_rr = rrIntervals.at<float>(i+1, 0) - rrIntervals.at<float>(i, 0);
        float diff_rr_squared = powf(diff_rr, 2.0f);
        
        sum_diff += diff_rr_squared;
    }
    
    float rmssd = sqrtf(sum_diff/n);
    
    return rmssd;
}

float computeRR50(cv::Mat rrIntervals,  int n)
{
    float rr50_counter = 0.0f;
    
    for(int i=0; i<(n-1); i++)
    {
        float diff_rr = rrIntervals.at<float>(i+1, 0) - rrIntervals.at<float>(i, 0);

        if (diff_rr > 0.05f)
            rr50_counter += 1.0f;
    }
    
    return rr50_counter;
}

float* featureExtraction(const CvMatPtr rawAccData, const CvMatPtr rawHRData)
{
    // Recover cv::Mat from CvMatPtr
    const cv::Mat& srcAcc = recoverMat(rawAccData);
    const cv::Mat& srcHR = recoverMat(rawHRData);

    cv::Mat heartRates = srcHR.col(0);
    cv::Mat rrIntervals = cv::Mat(srcHR.rows, 1, CV_32F);
    
    // Compute rr intervals
    for (int i=0; i<srcHR.rows; i++)
    {
        float rr = 60/srcHR.at<float>(i, 3);
        rrIntervals.row(i).col(0).setTo(cv::Scalar(rr));
    }

    cv::Mat x_axis = srcAcc.col(0);
    cv::Mat y_axis = srcAcc.col(1);
    cv::Mat z_axis = srcAcc.col(2);
    
    cv::Scalar meanCVHR, stdvHR;
    meanStdDev(heartRates, meanCVHR, stdvHR);
    float meanHR = static_cast<float>(meanCVHR.val[0]);
    float stdHR = static_cast<float>(stdvHR.val[0]);
    
    cv::Scalar meanCVRR, stdvRR;
    meanStdDev(heartRates, meanCVRR, stdvRR);
    float meanRR = static_cast<float>(meanCVRR.val[0]);
    float stdRR = static_cast<float>(stdvRR.val[0]);
    
    float rmssd = computeRMSSD(rrIntervals, srcHR.rows);
    float rr50 = computeRR50(rrIntervals, srcHR.rows);

    cv::Scalar meanCVX, stdvX;
    meanStdDev(x_axis, meanCVX, stdvX);
    float meanX = static_cast<float>(meanCVX.val[0]);
    float stdX = static_cast<float>(stdvX.val[0]);
    
    cv::Scalar meanCVY, stdvY;
    meanStdDev(y_axis, meanCVY, stdvY);
    float meanY = static_cast<float>(meanCVY.val[0]);
    float stdY = static_cast<float>(stdvY.val[0]);

    float activity = computeActivity(x_axis, y_axis, z_axis, srcAcc.rows);
    
    cv::Mat dftX = cv::Mat_<std::complex<float>>(srcAcc.rows, 1);
    dft(x_axis, dftX);
    cv::Mat dftY = cv::Mat_<std::complex<float>>(srcAcc.rows, 1);
    dft(y_axis, dftY);
    
    float energyX = 0.0f;
    float energyY = 0.0f;
    
    for (int i=0; i<srcAcc.rows; i++)
    {
        energyX += dftX.at<std::complex<float>>(i, 0).real()
            * dftX.at<std::complex<float>>(i, 0).imag();
        energyY += dftY.at<std::complex<float>>(i, 0).real()
            * dftY.at<std::complex<float>>(i, 0).imag();
    }
    
    static float features[13] = { meanHR, stdHR, meanRR, stdRR, rmssd, rr50,
        meanX, stdX, meanY, stdY, activity, energyX, energyY };
    
    return features;
}

// MARK: CLASSIFICATION

bool classifySVMStress(const CvMatPtr accInput, const CvMatPtr hrInput)
{
    // Get a reference to the main bundle & return SVM model path
    const char *path = read_svm_file();
    
    float* features = featureExtraction(accInput, hrInput);
    cv::Mat sampleMat = cv::Mat(1, 13, CV_32F, features);
    
    cv::Ptr<cv::ml::SVM> svm = cv::ml::SVM::load<cv::ml::SVM>(path);
    
    float response = svm->predict(sampleMat);
    
    if (response == 1)
        return true;
    else
        return false;
}

bool classifyDTStress(const CvMatPtr accInput, const CvMatPtr hrInput)
{
    // Get a reference to the main bundle & return DT model path
    const char *path = read_dt_file();
    
    float* features = featureExtraction(accInput, hrInput);
    cv::Mat sampleMat = cv::Mat(1, 13, CV_32F, features);
    
    cv::Ptr<cv::ml::DTrees> dt = cv::ml::DTrees::load<cv::ml::DTrees>(path);
    
    float response = dt->predict(sampleMat, cv::noArray(), cv::ml::DTrees::PREDICT_AUTO);
    
    if (response == 1)
        return true;
    else
        return false;
}