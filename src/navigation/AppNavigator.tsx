import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import LoginSelectionScreen from '../screens/LoginSelectionScreen';
import PatientLoginScreen from '../screens/PatientLoginScreen';
import DoctorLoginScreen from '../screens/DoctorLoginScreen';
import PatientDashboardScreen from '../screens/PatientDashboardScreen';
import DoctorDashboardScreen from '../screens/DoctorDashboardScreen';
import JointAssessmentScreen from '../screens/JointAssessmentScreen';

const Stack = createStackNavigator();

const AppNavigator = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="LoginSelection"
        screenOptions={{
          headerStyle: {
            backgroundColor: '#4CAF50',
          },
          headerTintColor: '#fff',
          headerTitleStyle: {
            fontWeight: 'bold',
          },
        }}
      >
        <Stack.Screen
          name="LoginSelection"
          component={LoginSelectionScreen}
          options={{ headerShown: false }}
        />
        <Stack.Screen
          name="PatientLogin"
          component={PatientLoginScreen}
          options={{ title: 'Patient Login' }}
        />
        <Stack.Screen
          name="DoctorLogin"
          component={DoctorLoginScreen}
          options={{ title: 'Doctor Login' }}
        />
        <Stack.Screen
          name="PatientDashboard"
          component={PatientDashboardScreen}
          options={{ title: 'Patient Dashboard' }}
        />
        <Stack.Screen
          name="DoctorDashboard"
          component={DoctorDashboardScreen}
          options={{ title: 'Doctor Dashboard' }}
        />
        <Stack.Screen
          name="JointAssessment"
          component={JointAssessmentScreen}
          options={{ title: 'Joint Assessment' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator; 