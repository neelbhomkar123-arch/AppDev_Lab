import DateTimePicker, {
  DateTimePickerEvent,
} from '@react-native-community/datetimepicker';
import Slider from '@react-native-community/slider';
import { Picker } from '@react-native-picker/picker';
import React, { useEffect, useState } from 'react';
import {
  Alert,
  FlatList,
  Platform,
  StyleSheet,
  TouchableOpacity,
  View
} from 'react-native';
import {
  Button,
  Card,
  Checkbox,
  Provider as PaperProvider,
  Paragraph,
  RadioButton,
  Text,
  TextInput,
  Title,
} from 'react-native-paper';

// --- Firebase Imports ---
import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  onSnapshot,
  updateDoc
} from 'firebase/firestore';
import { db } from '../../firebaseConfig';

// --- Define a type for our User data ---
interface User {
  id: string; // Firestore document ID
  name: string;
  email: string;
  phone: string;
  gender: string;
  course: string;
  age: number;
  dateOfBirth: string;
  termsAccepted: boolean;
}

export default function RegistrationScreen() {
  // --- Form State ---
  const [name, setName] = useState<string>('');
  const [email, setEmail] = useState<string>('');
  const [phone, setPhone] = useState<string>('');
  const [gender, setGender] = useState<string>('male');
  const [course, setCourse] = useState<string>('it');
  const [age, setAge] = useState<number>(18);
  const [termsAccepted, setTermsAccepted] = useState<boolean>(false);
  const [date, setDate] = useState<Date>(new Date());
  const [showDatePicker, setShowDatePicker] = useState<boolean>(false);

  // --- List State ---
  const [users, setUsers] = useState<User[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(false);

  // --- 2. READ Operation (Real-time) ---
  // This will fetch all users and listen for any changes
  useEffect(() => {
    // onSnapshot returns an "unsubscribe" function
    const unsubscribe = onSnapshot(collection(db, 'users'), (querySnapshot) => {
      const usersList: User[] = [];
      querySnapshot.forEach((doc) => {
        // Combine doc.id and doc.data() into a single User object
        usersList.push({ id: doc.id, ...doc.data() } as User);
      });
      setUsers(usersList);
    });

    // Cleanup the listener when the component unmounts
    return () => unsubscribe();
  }, []); // Empty dependency array means this runs once on mount

  // --- Date Picker Functions ---
  const onDateChange = (
    event: DateTimePickerEvent,
    selectedDate?: Date
  ) => {
    const currentDate = selectedDate || date;
    setShowDatePicker(Platform.OS === 'ios');
    setDate(currentDate);
  };

  const formatDate = (dateToFormat: Date): string => {
    return `${dateToFormat.getDate()}/${
      dateToFormat.getMonth() + 1
    }/${dateToFormat.getFullYear()}`;
  };

  // --- 1. CREATE Operation ---
  const handleSubmit = async () => {
    if (!name || !email) {
      Alert.alert('Validation Error', 'Please enter your name and email.');
      return;
    }
    if (!termsAccepted) {
      Alert.alert(
        'Validation Error',
        'You must accept the terms and conditions.'
      );
      return;
    }

    setIsLoading(true);
    try {
      const userToRegister = {
        name,
        email,
        phone,
        gender,
        course,
        age: Math.round(age),
        dateOfBirth: formatDate(date),
        termsAccepted,
      };

      await addDoc(collection(db, 'users'), userToRegister);
      Alert.alert(
        'Registration Successful!',
        'User data has been saved to Firestore.'
      );

      // Clear the form
      setName('');
      setEmail('');
      setPhone('');
      setGender('male');
      setCourse('it');
      setAge(18);
      setTermsAccepted(false);
      setDate(new Date());
    } catch (error) {
      console.error('Error adding document: ', error);
      Alert.alert('Error', 'Could not save data. Please try again.');
    }
    setIsLoading(false);
  };

  // --- 3. UPDATE Operation ---
  const handleUpdateUser = async (id: string) => {
    const userRef = doc(db, 'users', id);
    // For this example, let's just increment the age
    const user = users.find(u => u.id === id);
    const newAge = (user?.age || 0) + 1;

    try {
      await updateDoc(userRef, {
        age: newAge,
      });
      console.log('User Updated!');
      Alert.alert('Success', `Updated ${user?.name}'s age to ${newAge}`);
    } catch (e) {
      console.error('Error updating user: ', e);
      Alert.alert('Error', 'Could not update user.');
    }
  };

  // --- 4. DELETE Operation ---
  const handleDeleteUser = async (id: string) => {
    try {
      await deleteDoc(doc(db, 'users', id));
      console.log('User Deleted!');
      Alert.alert('Success', 'User deleted.');
    } catch (e) {
      console.error('Error deleting user: ', e);
      Alert.alert('Error', 'Could not delete user.');
    }
  };

  // --- Render Function for Each User in the List ---
  const renderUser = ({ item }: { item: User }) => (
    <Card style={styles.userCard}>
      <Card.Content>
        <Title>{item.name}</Title>
        <Paragraph>Email: {item.email}</Paragraph>
        <Paragraph>Age: {item.age}</Paragraph>
        <Paragraph>Course: {item.course}</Paragraph>
      </Card.Content>
      <Card.Actions>
        <Button onPress={() => handleUpdateUser(item.id)}>Update Age</Button>
        <Button
          onPress={() => handleDeleteUser(item.id)}
          color="#ff0000" // Make delete button red
        >
          Delete
        </Button>
      </Card.Actions>
    </Card>
  );

  // --- Form JSX ---
  // We put the form inside the ListHeaderComponent of the FlatList
  // This makes the form scrollable with the list
  const renderHeader = () => (
    <>
      <Card style={styles.card}>
        <Card.Content>
          <Title>Student Registration</Title>
          <Paragraph>Please fill out the form below.</Paragraph>

          <TextInput
            label="Full Name"
            value={name}
            onChangeText={setName}
            mode="outlined"
            style={styles.input}
            disabled={isLoading}
          />
          <TextInput
            label="Email Address"
            value={email}
            onChangeText={setEmail}
            keyboardType="email-address"
            autoCapitalize="none"
            mode="outlined"
            style={styles.input}
            disabled={isLoading}
          />
          <TextInput
            label="Phone Number"
            value={phone}
            onChangeText={setPhone}
            keyboardType="phone-pad"
            mode="outlined"
            style={styles.input}
            disabled={isLoading}
          />

          <View style={styles.fieldContainer}>
            <Text style={styles.label}>Gender</Text>
            <RadioButton.Group
              onValueChange={(newValue) => setGender(newValue)}
              value={gender}
            >
              <View style={styles.radioContainer}>
                <RadioButton.Item label="Male" value="male" />
                <RadioButton.Item label="Female" value="female" />
                <RadioButton.Item label="Other" value="other" />
              </View>
            </RadioButton.Group>
          </View>

          <TouchableOpacity onPress={() => !isLoading && setShowDatePicker(true)}>
            <TextInput
              label="Date of Birth"
              value={formatDate(date)}
              mode="outlined"
              style={styles.input}
              editable={false}
              right={<TextInput.Icon icon="calendar" />}
            />
          </TouchableOpacity>

          {showDatePicker && (
            <DateTimePicker
              testID="dateTimePicker"
              value={date}
              mode="date"
              display="default"
              onChange={onDateChange}
            />
          )}

          <View style={styles.fieldContainer}>
            <Text style={styles.label}>Select Course</Text>
            <View style={styles.pickerWrapper}>
              <Picker
                selectedValue={course}
                onValueChange={(itemValue) => setCourse(itemValue)}
                enabled={!isLoading}
              >
                <Picker.Item label="Information Technology" value="it" />
                <Picker.Item label="Computer Science" value="cs" />
                <Picker.Item label="Civil Engineering" value="civil" />
                <Picker.Item label="Electrical Engineering" value="elec" />
              </Picker>
            </View>
          </View>

          <View style={styles.fieldContainer}>
            <Text style={styles.label}>Age: {Math.round(age)}</Text>
            <Slider
              style={{ width: '100%', height: 40 }}
              minimumValue={16}
              maximumValue={60}
              minimumTrackTintColor="#6200ee"
              maximumTrackTintColor="#03dac4"
              thumbTintColor="#6200ee"
              value={age}
              onValueChange={setAge}
              disabled={isLoading}
            />
          </View>

          <Checkbox.Item
            label="I accept the Terms and Conditions"
            status={termsAccepted ? 'checked' : 'unchecked'}
            onPress={() => {
              setTermsAccepted(!termsAccepted);
            }}
            disabled={isLoading}
          />

          <Button
            mode="contained"
            onPress={handleSubmit}
            style={styles.button}
            labelStyle={styles.buttonText}
            loading={isLoading}
            disabled={isLoading}
          >
            {isLoading ? 'Submitting...' : 'Submit Registration'}
          </Button>
        </Card.Content>
      </Card>
      
      <Title style={styles.listTitle}>Registered Users</Title>
      {users.length === 0 && (
        <Text style={styles.emptyText}>No users registered yet.</Text>
      )}
    </>
  );

  return (
    <PaperProvider>
      <FlatList
        style={styles.container}
        data={users}
        renderItem={renderUser}
        keyExtractor={(item) => item.id}
        ListHeaderComponent={renderHeader} // The form is now the header
      />
    </PaperProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1, // Use flex: 1 for FlatList
    padding: 16,
    backgroundColor: '#f5f5f5',
  },
  card: {
    borderRadius: 8,
    elevation: 4,
    marginBottom: 24, // Add space below the form
  },
  input: {
    marginBottom: 16,
  },
  fieldContainer: {
    marginBottom: 16,
  },
  label: {
    fontSize: 16,
    marginBottom: 8,
    color: '#333',
  },
  radioContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
  },
  pickerWrapper: {
    borderWidth: 1,
    borderColor: '#888',
    borderRadius: 4,
  },
  button: {
    marginTop: 24,
    paddingVertical: 8,
  },
  buttonText: {
    fontSize: 16,
  },
  // --- New Styles for the User List ---
  listTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    marginLeft: 8,
    marginBottom: 12,
  },
  userCard: {
    borderRadius: 8,
    elevation: 2,
    marginBottom: 16,
  },
  emptyText: {
    textAlign: 'center',
    fontSize: 16,
    color: '#666',
    marginTop: 20,
  }
});

