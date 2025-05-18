import sqlite3

class Database:
    def __init__(self, db_name):
        self.conn = sqlite3.connect(db_name)
        self.cursor = self.conn.cursor()
        self.create_tables()

    def create_tables(self):
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS products (
                product_id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                price REAL NOT NULL
            )
        ''')
        
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS orders (
                order_id INTEGER PRIMARY KEY AUTOINCREMENT,
                total_price REAL NOT NULL,
                order_date TEXT NOT NULL
            )
        ''')
        
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS order_items (
                order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
                order_id INTEGER NOT NULL,
                product_id INTEGER NOT NULL,
                quantity INTEGER NOT NULL,
                FOREIGN KEY (order_id) REFERENCES orders(order_id),
                FOREIGN KEY (product_id) REFERENCES products(product_id)
            )
        ''')
        
        self.conn.commit()

class Admin:
    def __init__(self, db):
        self.db = db

    def add_product(self):
        name = input("Mahsulot nomi: ")
        price = float(input("Mahsulot narxi: "))
        self.db.cursor.execute("INSERT INTO products (name, price) VALUES (?, ?)", (name, price))
        self.db.conn.commit()
        print(f"{name} mahsuloti muvaffaqiyatli qo'shildi.")

    def view_products(self):
        self.db.cursor.execute("SELECT * FROM products")
        products = self.db.cursor.fetchall()
        print("Mahsulotlar ro'yxati:")
        for product in products:
            print(f"ID: {product[0]}, Nomi: {product[1]}, Narxi: {product[2]} so'm")

    def view_orders(self):
        self.db.cursor.execute("SELECT * FROM orders")
        orders = self.db.cursor.fetchall()
        print("Buyurtmalar ro'yxati:")
        for order in orders:
            print(f"\nBuyurtma ID: {order[0]}, Jami to'lov: {order[1]} so'm, Sana: {order[2]}")
            self.db.cursor.execute("SELECT product_id, quantity FROM order_items WHERE order_id = ?", (order[0],))
            items = self.db.cursor.fetchall()
            for item in items:
                self.db.cursor.execute("SELECT name FROM products WHERE product_id = ?", (item[0],))
                product_name = self.db.cursor.fetchone()[0]
                print(f"  Mahsulot: {product_name}, Soni: {item[1]}")

    def update_product(self):
        self.view_products()
        product_id = int(input("O'zgartirmoqchi bo'lgan mahsulot ID raqami: "))
        new_name = input("Yangi mahsulot nomi: ")
        new_price = float(input("Yangi mahsulot narxi: "))
        self.db.cursor.execute("UPDATE products SET name = ?, price = ? WHERE product_id = ?", (new_name, new_price, product_id))
        self.db.conn.commit()
        print("Mahsulot muvaffaqiyatli o'zgartirildi.")

    def delete_product(self):
        self.view_products()
        product_id = int(input("O'chirmoqchi bo'lgan mahsulot ID raqami: "))
        self.db.cursor.execute("DELETE FROM products WHERE product_id = ?", (product_id,))
        self.db.conn.commit()
        print("Mahsulot muvaffaqiyatli o'chirildi.")

    def admin_menu(self):
        while True:
            print("\nAdministrator menyusi:")
            print("1. Mahsulot qo'shish")
            print("2. Mahsulotlarni ko'rish")
            print("3. Mahsulotni o'zgartirish")
            print("4. Mahsulotni o'chirish")
            print("5. Mijoz buyurtmalarini ko'rish")
            print("6. Chiqish")
            choice = input("Tanlovingizni kiriting (1-6): ")

            if choice == '1':
                self.add_product()
            elif choice == '2':
                self.view_products()
            elif choice == '3':
                self.update_product()
            elif choice == '4':
                self.delete_product()
            elif choice == '5':
                self.view_orders()
            elif choice == '6':
                break
            else:
                print("Noto'g'ri tanlov. Qaytadan urinib ko'ring.")

class Customer:
    def __init__(self, db):
        self.db = db

    def view_products_customer(self):
        self.db.cursor.execute("SELECT * FROM products")
        products = self.db.cursor.fetchall()
        print("Mahsulotlar ro'yxati:")
        for product in products:
            print(f"ID: {product[0]}, Nomi: {product[1]}, Narxi: {product[2]} so'm")

    def place_order(self):
        cart = []
        while True:
            self.view_products_customer()
            product_id = int(input("Buyurtma berish uchun mahsulot ID raqamini kiriting (0 - tugatish): "))
            if product_id == 0:
                break
            quantity = int(input("Soni: "))
            cart.append((product_id, quantity))
        if cart:
            total_price = 0
            for item in cart:
                self.db.cursor.execute("SELECT price FROM products WHERE product_id = ?", (item[0],))
                price = self.db.cursor.fetchone()[0]
                total_price += price * item[1]
            self.db.cursor.execute("INSERT INTO orders (total_price, order_date) VALUES (?, datetime('now'))", (total_price,))
            order_id = self.db.cursor.lastrowid
            for item in cart:
                self.db.cursor.execute("INSERT INTO order_items (order_id, product_id, quantity) VALUES (?, ?, ?)", (order_id, item[0], item[1]))
            self.db.conn.commit()
            print(f"Buyurtmangiz qabul qilindi. Jami to'lov: {total_price} so'm")
        else:
            print("Buyurtma berilmadi.")

    def customer_menu(self):
        while True:
            print("\nMijoz menyusi:")
            print("1. Mahsulotlarni ko'rish")
            print("2. Buyurtma berish")
            print("3. Chiqish")
            choice = input("Tanlovingizni kiriting (1-3): ")

            if choice == '1':
                self.view_products_customer()
            elif choice == '2':
                self.place_order()
            elif choice == '3':
                break
            else:
                print("Noto'g'ri tanlov. Qaytadan urinib ko'ring.")

class Main:
    def __init__(self):
        self.db = Database('newera.db')
        self.admin = Admin(self.db)
        self.customer = Customer(self.db)

    def main_menu(self):
        while True:
            print("\nNewEra Cash & Carry tizimiga xush kelibsiz!")
            print("1. Administrator sifatida kirish")
            print("2. Mijoz sifatida kirish")
            print("3. Chiqish")
            choice = input("Tanlovingizni kiriting (1-3): ")

            if choice == '1':
                self.admin.admin_menu()
            elif choice == '2':
                self.customer.customer_menu()
            elif choice == '3':
                print("Dastur yakunlandi.")
                break
            else:
                print("Noto'g'ri tanlov. Qaytadan urinib ko'ring.")

if __name__ == '__main__':
    main_app = Main()
    main_app.main_menu()





