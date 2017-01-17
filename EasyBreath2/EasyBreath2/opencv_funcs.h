//
//  opencv_funcs.h
//  EasyBreath2
//
//  Created by Mark Zolotas on 27/02/2016.
//  Copyright © 2016 Charitos Charitou. All rights reserved.
//

#ifndef opencv_funcs_h
#define opencv_funcs_h // ← Include guard

#include "CvMat.h"
#include <stdio.h>

#ifdef __cplusplus
extern "C"{
#endif // ← For C/C++ compatibility
    
    // Trains a SVM classifier for stress
    float trainSVM();
    
    // Trains a DT classifier for stress
    float trainDT();
    
    // Classify stress using the SVM classifier trained with trainSVM()
    bool classifySVMStress(const CvMatPtr accFeatures, const CvMatPtr hrFeatures);
    
    // Classify stress using the DT classifier trained with trainDT()
    bool classifyDTStress(const CvMatPtr accFeatures, const CvMatPtr hrFeatures);

#ifdef __cplusplus
}
#endif // ← For C/C++ compatibility

#endif // opencv_funcs_h

