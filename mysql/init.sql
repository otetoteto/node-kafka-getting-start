-- debezium 用のユーザー作成
CREATE USER 'debezium'@'%' IDENTIFIED BY 'debezium_password';
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium'@'%';
FLUSH PRIVILEGES;

-- ユーザーテーブル
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ユーザーID',
    name VARCHAR(100) NOT NULL COMMENT 'ユーザー名',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT 'メールアドレス',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',

    INDEX idx_email (email)
) ENGINE=InnoDB CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ユーザー情報';

-- 注文イベントテーブル
CREATE TABLE IF NOT EXISTS order_events (
    event_id CHAR(36) PRIMARY KEY COMMENT 'イベントID（UUID）',
    event_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT 'イベント発生日時（マイクロ秒精度）',
    event_name VARCHAR(100) NOT NULL COMMENT 'イベント名',
    payload JSON NOT NULL COMMENT 'イベントペイロード',
    aggregate_id VARCHAR(100) NOT NULL COMMENT '集約ID',
    aggregate_name VARCHAR(100) NOT NULL COMMENT '集約名',

    INDEX idx_aggregate (aggregate_name, aggregate_id),
    INDEX idx_event_at (event_at),
    INDEX idx_event_name (event_name)
) ENGINE=InnoDB CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='注文イベント';

-- 注文テーブル
CREATE TABLE IF NOT EXISTS orders (
    id CHAR(36) PRIMARY KEY COMMENT '注文ID（UUID）',
    user_id INT NOT NULL COMMENT 'ユーザーID',
    product_name VARCHAR(200) NOT NULL COMMENT '商品名',
    quantity INT NOT NULL CHECK (quantity > 0) COMMENT '数量',
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0) COMMENT '単価',
    total_amount DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED COMMENT '合計金額',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '注文日時',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '作成日時',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',

    INDEX idx_user_id (user_id),
    INDEX idx_order_date (order_date),
		INDEX idx_product_name (product_name),

    CONSTRAINT fk_orders_user_id
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB CHARACTER SET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='注文情報';

-- サンプルデータ挿入
INSERT INTO users (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com');
