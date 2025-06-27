import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useNavigation } from '@react-navigation/native';

const PatientDashboardScreen = () => {
  const navigation = useNavigation();

  const navigateToJointAssessment = () => {
    navigation.navigate('JointAssessment');
  };

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Welcome to Your Dashboard</Text>
      
      <View style={styles.cardContainer}>
        <TouchableOpacity
          style={styles.card}
          onPress={navigateToJointAssessment}
        >
          <Text style={styles.cardTitle}>Joint Assessment</Text>
          <Text style={styles.cardDescription}>
            Complete your joint assessment to track your progress
          </Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.card}>
          <Text style={styles.cardTitle}>Exercise Plan</Text>
          <Text style={styles.cardDescription}>
            View and track your exercise routine
          </Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.card}>
          <Text style={styles.cardTitle}>Diet Plan</Text>
          <Text style={styles.cardDescription}>
            Access your personalized meal plans
          </Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.card}>
          <Text style={styles.cardTitle}>Health Records</Text>
          <Text style={styles.cardDescription}>
            View your medical history and reports
          </Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    padding: 20,
    color: '#333',
  },
  cardContainer: {
    padding: 16,
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 20,
    marginBottom: 16,
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#4CAF50',
    marginBottom: 8,
  },
  cardDescription: {
    fontSize: 14,
    color: '#666',
  },
});

export default PatientDashboardScreen; 