RENAME TABLE `intervention` TO `interventions`;

CREATE TABLE IF NOT EXISTS `labo_timer`.`groups` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `labo_timer`.`members` (
  `users_id` INT NOT NULL,
  `groups_id` INT NOT NULL,
  PRIMARY KEY (`users_id`, `groups_id`),
  INDEX `fk_members_groups1_idx` (`groups_id` ASC),
  CONSTRAINT `fk_members_users1`
    FOREIGN KEY (`users_id`)
    REFERENCES `labo_timer`.`users` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_members_groups1`
    FOREIGN KEY (`groups_id`)
    REFERENCES `labo_timer`.`groups` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;
