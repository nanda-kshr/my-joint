import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import Slider from '@react-native-community/slider';
import { useNavigation } from '@react-navigation/native';

// Define body regions and their joints
const bodyRegions = [
  {
    name: 'Head & Neck',
    joints: ['Temporomandibular', 'Cervical Spine']
  },
  {
    name: 'Upper Body',
    joints: ['Shoulder', 'Elbow', 'Wrist']
  },
  {
    name: 'Hands',
    joints: ['MCP', 'PIP', 'DIP', 'Thumb']
  },
  {
    name: 'Lower Body',
    joints: ['Hip', 'Knee', 'Ankle']
  },
  {
    name: 'Feet',
    joints: ['MTP', 'PIP', 'DIP']
  }
];

// Define assessment phases
enum AssessmentPhase {
  TENDER_JOINTS = 'TENDER_JOINTS',
  SWOLLEN_JOINTS = 'SWOLLEN_JOINTS',
  CLINICAL_ASSESSMENT = 'CLINICAL_ASSESSMENT',
  RESULTS = 'RESULTS'
}

const JointAssessment = () => {
  const navigation = useNavigation();
  const [currentPhase, setCurrentPhase] = useState<AssessmentPhase>(AssessmentPhase.TENDER_JOINTS);
  const [currentRegionIndex, setCurrentRegionIndex] = useState(0);
  const [tenderJoints, setTenderJoints] = useState<Set<string>>(new Set());
  const [swollenJoints, setSwollenJoints] = useState<Set<string>>(new Set());
  const [pgaValue, setPgaValue] = useState(0);
  const [egaValue, setEgaValue] = useState(0);
  const [crpValue, setCrpValue] = useState(0);
  const [sdaScore, setSdaScore] = useState<number | null>(null);

  const handleJointSelection = (joint: string) => {
    const isTenderPhase = currentPhase === AssessmentPhase.TENDER_JOINTS;
    const jointSet = isTenderPhase ? tenderJoints : swollenJoints;
    const setJointSet = isTenderPhase ? setTenderJoints : setSwollenJoints;

    const newJointSet = new Set(jointSet);
    if (newJointSet.has(joint)) {
      newJointSet.delete(joint);
    } else {
      newJointSet.add(joint);
    }
    setJointSet(newJointSet);
  };

  const calculateSDAIScore = () => {
    const tenderCount = tenderJoints.size;
    const swollenCount = swollenJoints.size;
    // Convert slider values to 0-10 scale for SDAI
    const pga = (pgaValue / 100) * 10;
    const ega = (egaValue / 100) * 10;
    const crp = crpValue;

    // SDAI calculation formula: SJC + TJC + PGA + EGA + CRP
    const score = tenderCount + swollenCount + pga + ega + crp;
    setSdaScore(parseFloat(score.toFixed(2)));
    setCurrentPhase(AssessmentPhase.RESULTS);
  };

  const handleNext = () => {
    if (currentPhase === AssessmentPhase.TENDER_JOINTS) {
      if (currentRegionIndex < bodyRegions.length - 1) {
        setCurrentRegionIndex(currentRegionIndex + 1);
      } else {
        setCurrentPhase(AssessmentPhase.SWOLLEN_JOINTS);
        setCurrentRegionIndex(0);
      }
    } else if (currentPhase === AssessmentPhase.SWOLLEN_JOINTS) {
      if (currentRegionIndex < bodyRegions.length - 1) {
        setCurrentRegionIndex(currentRegionIndex + 1);
      } else {
        setCurrentPhase(AssessmentPhase.CLINICAL_ASSESSMENT);
      }
    }
  };

  const handlePrevious = () => {
    if (currentPhase === AssessmentPhase.SWOLLEN_JOINTS) {
      if (currentRegionIndex > 0) {
        setCurrentRegionIndex(currentRegionIndex - 1);
      } else {
        setCurrentPhase(AssessmentPhase.TENDER_JOINTS);
        setCurrentRegionIndex(bodyRegions.length - 1);
      }
    } else if (currentPhase === AssessmentPhase.TENDER_JOINTS) {
      if (currentRegionIndex > 0) {
        setCurrentRegionIndex(currentRegionIndex - 1);
      }
    } else if (currentPhase === AssessmentPhase.CLINICAL_ASSESSMENT) {
      setCurrentPhase(AssessmentPhase.SWOLLEN_JOINTS);
      setCurrentRegionIndex(bodyRegions.length - 1);
    } else if (currentPhase === AssessmentPhase.RESULTS) {
      setCurrentPhase(AssessmentPhase.CLINICAL_ASSESSMENT);
    }
  };

  const renderJointSelectionPhase = () => {
    const isTenderPhase = currentPhase === AssessmentPhase.TENDER_JOINTS;
    const currentRegion = bodyRegions[currentRegionIndex];
    const selectedJoints = isTenderPhase ? tenderJoints : swollenJoints;

    return (
      <View style={styles.phaseContainer}>
        <Text style={styles.phaseTitle}>
          {isTenderPhase ? 'Tender' : 'Swollen'} Joint Assessment
        </Text>
        <Text style={styles.phaseSubtitle}>
          Select all {isTenderPhase ? 'tender' : 'swollen'} joints in the {currentRegion.name} region
        </Text>
        <ScrollView style={styles.jointsList}>
          {currentRegion.joints.map((joint) => (
            <TouchableOpacity
              key={joint}
              style={[
                styles.jointButton,
                selectedJoints.has(joint) && styles.selectedJoint
              ]}
              onPress={() => handleJointSelection(joint)}
            >
              <Text style={styles.jointText}>{joint}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
        <Text style={styles.countText}>
          {isTenderPhase ? 'Tender' : 'Swollen'} Joints: {selectedJoints.size}
        </Text>
      </View>
    );
  };

  const renderClinicalAssessmentPhase = () => (
    <View style={styles.phaseContainer}>
      <Text style={styles.phaseTitle}>Clinical Assessment</Text>
      <ScrollView style={styles.sliderContainer}>
        <View style={styles.sliderSection}>
          <Text style={styles.sliderLabel}>PGA (Physician Global Assessment)</Text>
          <Text style={styles.sliderDescription}>Rate your overall disease activity (0-100mm)</Text>
          <Slider
            style={styles.slider}
            minimumValue={0}
            maximumValue={100}
            value={pgaValue}
            onValueChange={setPgaValue}
            minimumTrackTintColor="#4CAF50"
            maximumTrackTintColor="#000000"
          />
          <Text style={styles.sliderValue}>{pgaValue.toFixed(0)} mm</Text>
        </View>

        <View style={styles.sliderSection}>
          <Text style={styles.sliderLabel}>EGA (Evaluator Global Assessment)</Text>
          <Text style={styles.sliderDescription}>Rate your overall disease activity (0-100mm)</Text>
          <Slider
            style={styles.slider}
            minimumValue={0}
            maximumValue={100}
            value={egaValue}
            onValueChange={setEgaValue}
            minimumTrackTintColor="#4CAF50"
            maximumTrackTintColor="#000000"
          />
          <Text style={styles.sliderValue}>{egaValue.toFixed(0)} mm</Text>
        </View>

        <View style={styles.sliderSection}>
          <Text style={styles.sliderLabel}>CRP (C-Reactive Protein)</Text>
          <Text style={styles.sliderDescription}>Enter your CRP value (0-300 mg/L)</Text>
          <Slider
            style={styles.slider}
            minimumValue={0}
            maximumValue={300}
            value={crpValue}
            onValueChange={setCrpValue}
            minimumTrackTintColor="#4CAF50"
            maximumTrackTintColor="#000000"
          />
          <Text style={styles.sliderValue}>{crpValue.toFixed(0)} mg/L</Text>
        </View>
      </ScrollView>
      <TouchableOpacity
        style={[styles.navigationButton, styles.calculateButton]}
        onPress={calculateSDAIScore}
      >
        <Text style={styles.navigationButtonText}>Calculate SDAI</Text>
      </TouchableOpacity>
    </View>
  );

  const renderResultsPhase = () => (
    <View style={styles.phaseContainer}>
      <Text style={styles.phaseTitle}>Assessment Results</Text>
      <View style={styles.resultsContainer}>
        <Text style={styles.resultText}>Tender Joints: {tenderJoints.size}</Text>
        <Text style={styles.resultText}>Swollen Joints: {swollenJoints.size}</Text>
        <Text style={styles.resultText}>PGA: {pgaValue.toFixed(0)} mm</Text>
        <Text style={styles.resultText}>EGA: {egaValue.toFixed(0)} mm</Text>
        <Text style={styles.resultText}>CRP: {crpValue.toFixed(0)} mg/L</Text>
        <Text style={styles.scoreText}>SDAI Score: {sdaScore}</Text>
      </View>
    </View>
  );

  const renderCurrentPhase = () => {
    switch (currentPhase) {
      case AssessmentPhase.TENDER_JOINTS:
      case AssessmentPhase.SWOLLEN_JOINTS:
        return renderJointSelectionPhase();
      case AssessmentPhase.CLINICAL_ASSESSMENT:
        return renderClinicalAssessmentPhase();
      case AssessmentPhase.RESULTS:
        return renderResultsPhase();
    }
  };

  return (
    <View style={styles.container}>
      {renderCurrentPhase()}
      <View style={styles.navigationContainer}>
        {(currentPhase === AssessmentPhase.TENDER_JOINTS && currentRegionIndex > 0) ||
         currentPhase === AssessmentPhase.SWOLLEN_JOINTS ||
         currentPhase === AssessmentPhase.CLINICAL_ASSESSMENT ||
         currentPhase === AssessmentPhase.RESULTS ? (
          <TouchableOpacity
            style={styles.navigationButton}
            onPress={handlePrevious}
          >
            <Text style={styles.navigationButtonText}>Previous</Text>
          </TouchableOpacity>
        ) : null}
        
        {currentPhase === AssessmentPhase.CLINICAL_ASSESSMENT ? (
          <TouchableOpacity
            style={styles.navigationButton}
            onPress={calculateSDAIScore}
          >
            <Text style={styles.navigationButtonText}>Calculate SDAI</Text>
          </TouchableOpacity>
        ) : currentPhase === AssessmentPhase.RESULTS ? (
          <TouchableOpacity
            style={styles.navigationButton}
            onPress={() => navigation.goBack()}
          >
            <Text style={styles.navigationButtonText}>Finish</Text>
          </TouchableOpacity>
        ) : (
          <TouchableOpacity
            style={styles.navigationButton}
            onPress={handleNext}
          >
            <Text style={styles.navigationButtonText}>Next</Text>
          </TouchableOpacity>
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 20,
  },
  phaseContainer: {
    flex: 1,
  },
  phaseTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#333',
  },
  phaseSubtitle: {
    fontSize: 16,
    color: '#666',
    marginBottom: 20,
  },
  jointsList: {
    flex: 1,
  },
  jointButton: {
    padding: 15,
    backgroundColor: '#f0f0f0',
    borderRadius: 8,
    marginBottom: 8,
  },
  selectedJoint: {
    backgroundColor: '#4CAF50',
  },
  jointText: {
    fontSize: 16,
    color: '#333',
  },
  countText: {
    fontSize: 18,
    fontWeight: '600',
    marginTop: 20,
    color: '#444',
  },
  sliderContainer: {
    flex: 1,
  },
  sliderSection: {
    marginBottom: 30,
  },
  sliderLabel: {
    fontSize: 16,
    marginBottom: 10,
    color: '#444',
  },
  slider: {
    width: '100%',
    height: 40,
  },
  sliderValue: {
    fontSize: 16,
    textAlign: 'center',
    marginTop: 5,
    color: '#666',
  },
  resultsContainer: {
    padding: 20,
    backgroundColor: '#f8f8f8',
    borderRadius: 10,
  },
  resultText: {
    fontSize: 18,
    marginBottom: 10,
    color: '#444',
  },
  scoreText: {
    fontSize: 24,
    fontWeight: 'bold',
    marginTop: 20,
    color: '#4CAF50',
  },
  navigationContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 20,
  },
  navigationButton: {
    backgroundColor: '#4CAF50',
    padding: 15,
    borderRadius: 8,
    minWidth: 120,
    alignItems: 'center',
  },
  navigationButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  sliderDescription: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
  },
  calculateButton: {
    marginTop: 20,
    backgroundColor: '#2196F3',
  },
});

export default JointAssessment; 