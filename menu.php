<?php
require_once 'config.php';
require_once 'header.php';

$conn = getDBConnection();

// Handle form submission for adding new menu item
if($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['add_item'])) {
    $item_name = $_POST['item_name'];
    $description = $_POST['description'];
    $category = $_POST['category'];
    $subcategory = $_POST['subcategory'];
    $price = $_POST['price'];
    $cost = $_POST['cost'];
    $preparation_time = $_POST['preparation_time'];
    $calories = $_POST['calories'];
    $dietary_tags = $_POST['dietary_tags'];
    
    $stmt = $conn->prepare("INSERT INTO MenuItems (item_name, description, category, subcategory, price, cost, preparation_time, calories, dietary_tags) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssddiis", $item_name, $description, $category, $subcategory, $price, $cost, $preparation_time, $calories, $dietary_tags);
    
    if($stmt->execute()) {
        $success = "Menu item added successfully!";
    } else {
        $error = "Error adding menu item: " . $stmt->error;
    }
    
    $stmt->close();
}

// Get all menu items
$result = $conn->query("SELECT * FROM MenuItems ORDER BY category, subcategory, item_name");
$menu_items = $result->fetch_all(MYSQLI_ASSOC);

closeDBConnection($conn);
?>

<h2>Menu Management</h2>

<?php if(isset($success)): ?>
    <div style="color: green; margin-bottom: 15px;"><?php echo $success; ?></div>
<?php endif; ?>

<?php if(isset($error)): ?>
    <div style="color: red; margin-bottom: 15px;"><?php echo $error; ?></div>
<?php endif; ?>

<div style="display: grid; grid-template-columns: 1fr 2fr; gap: 20px;">
    <div class="card">
        <div class="card-header">
            <h3>Add New Menu Item</h3>
        </div>
        <div style="padding: 20px;">
            <form method="POST" action="menu.php">
                <div class="form-group">
                    <label for="item_name">Item Name:</label>
                    <input type="text" id="item_name" name="item_name" required>
                </div>
                
                <div class="form-group">
                    <label for="description">Description:</label>
                    <textarea id="description" name="description" rows="3"></textarea>
                </div>
                
                <div class="form-group">
                    <label for="category">Category:</label>
                    <input type="text" id="category" name="category" required>
                </div>
                
                <div class="form-group">
                    <label for="subcategory">Subcategory:</label>
                    <input type="text" id="subcategory" name="subcategory">
                </div>
                
                <div class="form-group">
                    <label for="price">Price ($):</label>
                    <input type="number" id="price" name="price" step="0.01" min="0" required>
                </div>
                
                <div class="form-group">
                    <label for="cost">Cost ($):</label>
                    <input type="number" id="cost" name="cost" step="0.01" min="0" required>
                </div>
                
                <div class="form-group">
                    <label for="preparation_time">Preparation Time (minutes):</label>
                    <input type="number" id="preparation_time" name="preparation_time" min="1" required>
                </div>
                
                <div class="form-group">
                    <label for="calories">Calories:</label>
                    <input type="number" id="calories" name="calories" min="0">
                </div>
                
                <div class="form-group">
                    <label for="dietary_tags">Dietary Tags:</label>
                    <input type="text" id="dietary_tags" name="dietary_tags" placeholder="e.g., vegetarian, gluten-free">
                </div>
                
                <button type="submit" name="add_item">Add Item</button>
            </form>
        </div>
    </div>
    
    <div class="card">
        <div class="card-header">
            <h3>Current Menu Items</h3>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Item Name</th>
                    <th>Category</th>
                    <th>Price</th>
                    <th>Cost</th>
                    <th>Prep Time</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach($menu_items as $item): ?>
                <tr>
                    <td><?php echo $item['item_name']; ?></td>
                    <td><?php echo $item['category']; ?><?php echo $item['subcategory'] ? ' / ' . $item['subcategory'] : ''; ?></td>
                    <td>$<?php echo number_format($item['price'], 2); ?></td>
                    <td>$<?php echo number_format($item['cost'], 2); ?></td>
                    <td><?php echo $item['preparation_time']; ?> min</td>
                    <td><?php echo $item['is_available'] ? 'Available' : 'Unavailable'; ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once 'footer.php'; ?>