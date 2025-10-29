import React, { useEffect, useState } from "react";
import {
  Alert,
  FlatList,
  SafeAreaView,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View
} from "react-native";

// ✅ Correct import for Expo
import { openDatabaseAsync, SQLiteDatabase } from "expo-sqlite";

type Task = {
  id: number;
  task: string;
  email: string;
  date: string;
};

export default function App() {
  const [db, setDb] = useState<SQLiteDatabase | null>(null);
  const [task, setTask] = useState("");
  const [email, setEmail] = useState("");
  const [date, setDate] = useState("");
  const [tasks, setTasks] = useState<Task[]>([]);

  // ✅ Initialize database
  useEffect(() => {
    const initDb = async () => {
      const database = await openDatabaseAsync("mydb.db");
      setDb(database);

      await database.execAsync(`
        CREATE TABLE IF NOT EXISTS tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          task TEXT,
          email TEXT,
          date TEXT
        );
      `);

      loadTasks(database);
    };
    initDb();
  }, []);

  // ✅ Load all tasks
  const loadTasks = async (database?: SQLiteDatabase) => {
    if (!db && !database) return;
    const currentDb = database || db;
    const result = await currentDb!.getAllAsync<Task>("SELECT * FROM tasks;");
    setTasks(result);
  };

  // ✅ Add new task
  const addTask = async () => {
    if (!db) return;
    if (!task.trim() || !email.trim() || !date.trim()) {
      Alert.alert("Error", "Please fill all fields");
      return;
    }

    await db.runAsync("INSERT INTO tasks (task, email, date) VALUES (?, ?, ?);", [
      task,
      email,
      date,
    ]);
    setTask("");
    setEmail("");
    setDate("");
    loadTasks();
  };

  // ✅ Update a task
  const updateTask = async (id: number) => {
    if (!db) return;
    await db.runAsync("UPDATE tasks SET task=? WHERE id=?;", ["Updated Task", id]);
    loadTasks();
  };

  // ✅ Delete a task
  const deleteTask = async (id: number) => {
    if (!db) return;
    await db.runAsync("DELETE FROM tasks WHERE id=?;", [id]);
    loadTasks();
  };

  const confirmDelete = (id: number) => {
    Alert.alert("Delete Task", "Are you sure?", [
      { text: "Cancel", style: "cancel" },
      { text: "OK", onPress: () => deleteTask(id) },
    ]);
  };

  // --- UI FOR LIST ITEMS (MODIFIED) ---
  const renderItem = ({ item }: { item: Task }) => (
    <View style={styles.taskItem}>
      <View style={styles.taskInfo}>
        <Text style={styles.taskText}>Task: {item.task}</Text>
        <Text style={styles.emailText}>Email: {item.email}</Text>
        <Text style={styles.dateText}>Date: {item.date}</Text>
      </View>
      {/* --- Button layout is now horizontal --- */}
      <View style={styles.buttonContainer}>
        <TouchableOpacity
          style={[styles.button, styles.editButton]}
          onPress={() => updateTask(item.id)}
        >
          <Text style={styles.buttonText}>Edit</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.button, styles.deleteButton]}
          onPress={() => confirmDelete(item.id)}
        >
          <Text style={styles.buttonText}>Delete</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      {/* --- Added a title --- */}
      <Text style={styles.title}>Task Manager</Text>

      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          placeholder="Enter Task"
          placeholderTextColor="#999"
          value={task}
          onChangeText={setTask}
        />
        <TextInput
          style={styles.input}
          placeholder="Enter Email"
          placeholderTextColor="#999"
          value={email}
          onChangeText={setEmail}
        />
        <TextInput
          style={styles.input}
          placeholder="Enter Date (e.g., 09-10-2025)"
          placeholderTextColor="#999"
          value={date}
          onChangeText={setDate}
        />
        {/* --- Replaced default Button with TouchableOpacity for styling --- */}
        <TouchableOpacity style={styles.addButton} onPress={addTask}>
          <Text style={styles.addButtonText}>Add Task</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={tasks}
        keyExtractor={(item) => item.id.toString()}
        renderItem={renderItem}
        ListEmptyComponent={<Text style={styles.emptyText}>No tasks yet. Add one!</Text>}
      />
    </SafeAreaView>
  );
}

// --- ALL STYLES HAVE BEEN UPDATED ---
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#f9f9f9", // Lighter background
    padding: 16,
  },
  title: {
    fontSize: 28,
    fontWeight: "bold",
    textAlign: "center",
    marginBottom: 24,
    color: "#333",
  },
  inputContainer: {
    marginBottom: 20,
    backgroundColor: "#fff",
    borderRadius: 12,
    padding: 20,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  input: {
    height: 48,
    borderColor: "#ddd",
    borderWidth: 1,
    borderRadius: 8,
    paddingHorizontal: 15,
    marginBottom: 12,
    backgroundColor: "#fff",
    fontSize: 16,
  },
  addButton: {
    backgroundColor: "#4A90E2", // New primary color
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: "center",
    marginTop: 8,
  },
  addButtonText: {
    color: "#fff",
    fontWeight: "bold",
    fontSize: 16,
  },
  taskItem: {
    backgroundColor: "#fff",
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 2,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  taskInfo: {
    flex: 1, // Allow text to take available space
    marginRight: 10,
  },
  taskText: {
    fontSize: 16,
    fontWeight: "600",
    color: "#333",
  },
  emailText: {
    fontSize: 14,
    color: "#555",
    marginTop: 4,
  },
  dateText: {
    fontSize: 13,
    color: "#888",
    marginTop: 2,
  },
  buttonContainer: {
    flexDirection: "row", // Horizontal buttons
  },
  button: {
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 6,
    marginLeft: 8,
  },
  editButton: {
    backgroundColor: "#F5A623", // Orange for edit
  },
  deleteButton: {
    backgroundColor: "#D0021B", // Red for delete
  },
  buttonText: {
    color: "#fff",
    fontWeight: "bold",
    fontSize: 12,
  },
  emptyText: {
    textAlign: 'center',
    marginTop: 30,
    fontSize: 16,
    color: '#888',
  },
});

