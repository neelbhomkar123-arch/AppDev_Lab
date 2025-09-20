import React, { useState } from 'react';



const View = ({ children, className = '' }) => <div className={className}>{children}</div>;
const Text = ({ children, className = '' }) => <p className={className}>{children}</p>;
const TextInput = (props) => <input {...props} />;
const TouchableOpacity = ({ children, ...props }) => <button {...props}>{children}</button>;



export default function App() {
  const [tasks, setTasks] = useState([
    { id: 1, text: 'Read a book', completed: false },
    { id: 2, text: 'Write some code', completed: true },
    { id: 3, text: 'Go for a run', completed: false },
  ]);
  const [inputText, setInputText] = useState('');

  const handleAddTask = () => {
    if (inputText.trim() === '') {
      
      console.log("Cannot add an empty task.");
      return;
    }
    const newTask = {
      id: Date.now(), 
      text: inputText.trim(),
      completed: false,
    };
    setTasks([...tasks, newTask]);
    setInputText(''); /

  const handleToggleTask = (id) => {
    setTasks(
      tasks.map((task) =>
        task.id === id ? { ...task, completed: !task.completed } : task
      )
    );
  };

  const handleDeleteTask = (id) => {
    setTasks(tasks.filter((task) => task.id !== id));
  };


  
  return (
    
    <View className="bg-gray-100 w-full min-h-screen flex items-center font-sans">
      <View className="w-full max-w-md mx-auto p-4 mt-8">
        
        {/* Header */}
        <View className="mb-6">
            <Text className="text-4xl font-bold text-gray-800 text-center">To-Do List</Text>
        </View>

        {/* Input Area */}
        <View className="flex flex-row gap-2 mb-6">
          <TextInput
            className="flex-1 p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 transition-shadow"
            placeholder="Add a new task..."
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleAddTask()}
          />
          <TouchableOpacity
            className="px-6 py-3 bg-blue-500 text-white font-semibold rounded-lg shadow hover:bg-blue-600 active:scale-95 transition-all duration-200"
            onClick={handleAddTask}
          >
            Add
          </TouchableOpacity>
        </View>

        {/* Task List */}
        {/* In React Native, this would be a <FlatList> component */}
        <View>
          {tasks.length > 0 ? (
            tasks.map(item => (
              <View key={item.id} className="flex flex-row items-center justify-between p-4 mb-3 bg-white rounded-lg shadow transition-all duration-200 ease-in-out">
                <TouchableOpacity
                  className="flex-1 flex-row items-center"
                  onClick={() => handleToggleTask(item.id)}
                >
                  <View className={`w-6 h-6 mr-4 rounded-full flex items-center justify-center border-2 ${item.completed ? 'bg-blue-500 border-blue-500' : 'border-gray-300'}`}>
                    {item.completed && (
                      <Text className="text-white text-sm font-bold">✓</Text>
                    )}
                  </View>
                  <Text className={`text-gray-700 ${item.completed ? 'line-through text-gray-400' : ''}`}>
                    {item.text}
                  </Text>
                </TouchableOpacity>
                <TouchableOpacity
                  className="p-2 rounded-full hover:bg-red-100 transition-colors duration-200"
                  onClick={() => handleDeleteTask(item.id)}
                >
                  <Text className="text-red-500 text-lg">✕</Text>
                </TouchableOpacity>
              </View>
            ))
          ) : (
            <View className="text-center p-8 bg-white rounded-lg shadow">
                <Text className="text-gray-500">No tasks yet. Add one!</Text>
            </View>
          )}
        </View>

      </View>
    </View>
  );
}