import React, { useState } from 'react';
import { View, TextInput, Button, Text, StyleSheet, Alert } from 'react-native';
import { initializeApp } from 'firebase/app';
import { getAuth, createUserWithEmailAndPassword, signInWithEmailAndPassword } from 'firebase/auth';
import { firebaseConfig } from '../firebaseConfig';

// Initialize Firebase only once
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

export default function AuthScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [user, setUser] = useState<any>(null);

  const handleSignup = async () => {
    try {
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      setUser(userCredential.user);
      Alert.alert('Signup Successful');
    } catch (error: any) {
      Alert.alert('Error', error.message);
    }
  };

  const handleLogin = async () => {
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      setUser(userCredential.user);
      Alert.alert('Login Successful');
    } catch (error: any) {
      Alert.alert('Error', error.message);
    }
  };

  const handleLogout = async () => {
    setUser(null);
    Alert.alert('Logged Out');
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Firebase Auth Example</Text>
      {!user ? (
        <>
          <TextInput
            style={styles.input}
            placeholder="Email"
            value={email}
            onChangeText={setEmail}
            keyboardType="email-address"
            autoCapitalize="none"
          />
          <TextInput
            style={styles.input}
            placeholder="Password"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
          />
          <View style={styles.buttonContainer}>
            <Button title="Sign Up" onPress={handleSignup} />
            <Button title="Login" onPress={handleLogin} />
          </View>
        </>
      ) : (
        <>
          <Text style={styles.text}>Welcome, {user.email}</Text>
          <Button title="Logout" onPress={handleLogout} />
        </>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#f0f4f7',
  },
  title: {
    fontSize: 22,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  input: {
    width: '100%',
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 8,
    padding: 10,
    marginBottom: 10,
    backgroundColor: '#fff',
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: '100%',
    marginTop: 10,
  },
  text: {
    fontSize: 18,
    marginBottom: 20,
  },
});
