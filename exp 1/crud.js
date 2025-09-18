
let fruits = ["Apple", "Banana", "Mango"];


function createFruit(fruit) {
  fruits.push(fruit);
  console.log(`Added: ${fruit}`);
}


function readFruits() {
  console.log("Fruits:", fruits);
}


function updateFruit(index, newFruit) {
  if (index >= 0 && index < fruits.length) {
    console.log(`Updated: ${fruits[index]} -> ${newFruit}`);
    fruits[index] = newFruit;
  } else {
    console.log("Invalid index!");
  }
}


function deleteFruit(index) {
  if (index >= 0 && index < fruits.length) {
    console.log(`Deleted: ${fruits[index]}`);
    fruits.splice(index, 1);
  } else {
    console.log("Invalid index!");
  }
}

// --- Example Usage ---
readFruits();             // Read initial array
createFruit("Orange");    // Add a fruit
readFruits();             // View after create
updateFruit(1, "Grapes"); // Update Banana -> Grapes
readFruits();             // View after update
deleteFruit(2);           // Delete Mango
readFruits();             // View after delete
