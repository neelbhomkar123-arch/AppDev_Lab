Aim : Write a simple program in JavaScript/TypeScript to perform CRUD on an array.

steps followed : 1️. Initialize the Array Start with a sample array: let fruits = ["Apple", "Banana", "Mango"];

2️. CREATE (Add an Element) Use push() to add a new item to the array. Example: fruits.push("Orange");

3️. READ (View the Array) Use console.log() to display the entire array. Example: console.log(fruits);

4️. UPDATE (Modify an Element) Access the array by index and assign a new value. Example: fruits[1] = "Grapes"; // Replaces "Banana" with "Grapes"

5️. DELETE (Remove an Element) Use splice(index, 1) to remove an element at a specific index. Example: fruits.splice(2, 1); // Removes the third item ("Mango")

6️. Test Each Operation Call the functions in order to check each CRUD action: console.log(fruits); // Read fruits.push("Orange"); // Create fruits[1] = "Grapes"; // Update fruits.splice(2, 1); // Delete console.log(fruits); // Read again

Expected output

Fruits: [ 'Apple', 'Banana', 'Mango' ] Added: Orange Fruits: [ 'Apple', 'Banana', 'Mango', 'Orange' ] Updated: Banana -> Grapes Fruits: [ 'Apple', 'Grapes', 'Mango', 'Orange' ] Deleted: Mango Fruits: [ 'Apple', 'Grapes', 'Orange' ]