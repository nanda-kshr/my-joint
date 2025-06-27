import React from 'react';
import { View, StyleSheet } from 'react-native';
import JointAssessment from '../components/JointAssessment';

const JointAssessmentScreen = () => {
  return (
    <View style={styles.container}>
      <JointAssessment />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
});

export default JointAssessmentScreen; 