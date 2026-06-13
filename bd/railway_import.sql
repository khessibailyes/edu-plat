SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

-- Tables

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `full_name` varchar(120) NOT NULL,
  `email` varchar(180) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','teacher','student') NOT NULL DEFAULT 'student',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `documents` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `teacher_id` int(10) UNSIGNED NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `description` text DEFAULT NULL,
  `upload_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `messages` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `sender_id` int(10) UNSIGNED NOT NULL,
  `receiver_id` varchar(20) NOT NULL COMMENT 'all or a user id',
  `content` text NOT NULL,
  `type` enum('private','public') NOT NULL DEFAULT 'private',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `sender_id` (`sender_id`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `products` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_name` varchar(200) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock_quantity` int(10) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Views (without DEFINER for Railway compatibility)

CREATE VIEW `view_products_by_price` AS
  SELECT `id`, `product_name`, `price`, `stock_quantity`
  FROM `products` ORDER BY `price` ASC;

CREATE VIEW `view_products_mid_stock` AS
  SELECT `id`, `product_name`, `price`, `stock_quantity`
  FROM `products` WHERE `stock_quantity` >= 10 AND `stock_quantity` <= 30;

CREATE VIEW `view_users_alphabetical` AS
  SELECT `id`, `full_name`, `email`, `role`, `created_at`
  FROM `users` ORDER BY `full_name` ASC;

-- Data: users (passwords are bcrypt hashed)

INSERT INTO `users` (`id`, `full_name`, `email`, `password`, `role`, `created_at`) VALUES
(1, 'Administrator', 'admin@gmail.com', '$2y$12$/vb02R0G2WD7H0z8tiIn6ebWrkiPcW98XWWZGN1SbJaDL7vev55fW', 'admin', '2026-04-23 07:39:01'),
(2, 'btp informatique', 'btpinformatique8@gmail.com', '$2y$12$VxU1SlAkUfPfRzjr0OXMEOpVAO4YBOGOdeL9OkvUHC7iyirN8GaVW', 'student', '2026-04-23 07:41:10'),
(3, 'imen hmida', 'imen@gmail.com', '$2y$12$O7UtSLcxW8cLBcruFejob.B5cg/C50uvNT23njEcZTcMRtj3aeUX6', 'teacher', '2026-04-24 08:39:14'),
(4, 'Administrator', 'admin@edu.local', '$2y$12$/vb02R0G2WD7H0z8tiIn6ebWrkiPcW98XWWZGN1SbJaDL7vev55fW', 'admin', '2026-05-07 08:57:38');

-- Data: messages

INSERT INTO `messages` (`id`, `sender_id`, `receiver_id`, `content`, `type`, `timestamp`) VALUES
(1, 1, 'all', 'tfgjhfgjnfgjfj', 'public', '2026-04-24 08:37:38'),
(2, 3, '2', 'fghbfdhbfgb', 'private', '2026-04-24 08:40:03');

-- Data: products

INSERT INTO `products` (`id`, `product_name`, `price`, `stock_quantity`) VALUES
(1, 'Mathematics Textbook', 29.99, 5),
(2, 'Physics Workbook', 19.99, 15),
(3, 'Chemistry Lab Guide', 34.50, 10),
(4, 'Biology Atlas', 45.00, 30),
(5, 'History Compendium', 22.00, 50),
(6, 'Literature Anthology', 18.75, 25),
(7, 'Programming Handbook', 55.00, 8),
(8, 'Art & Design Manual', 40.00, 20);
