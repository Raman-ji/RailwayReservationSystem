# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_10_09_095216) do
  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.integer "resource_id"
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "availables", force: :cascade do |t|
    t.date "dates"
    t.integer "_2AC_available"
    t.integer "_1AC_available"
    t.integer "general_available"
    t.integer "train_detail_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["train_detail_id"], name: "index_availables_on_train_detail_id"
  end

  create_table "passengers", force: :cascade do |t|
    t.string "passenger_name"
    t.string "date_of_birth"
    t.string "gender"
    t.text "seat_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reservation_id", null: false
    t.index ["reservation_id"], name: "index_passengers_on_reservation_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.date "date"
    t.text "pnr"
    t.string "berth_class"
    t.text "ticket_status"
    t.text "payment_status"
    t.string "email"
    t.integer "phone_number"
    t.integer "train_detail_id", null: false
    t.integer "available_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available_id"], name: "index_reservations_on_available_id"
    t.index ["train_detail_id"], name: "index_reservations_on_train_detail_id"
  end

  create_table "searches", force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "seats", force: :cascade do |t|
    t.date "dates"
    t.text "available_2AC_seats"
    t.text "occupied_2AC_seats"
    t.text "available_1AC_seats"
    t.text "occupied_1AC_seats"
    t.text "available_general_seats"
    t.text "occupied_general_seats"
    t.integer "train_detail_id", null: false
    t.integer "available_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available_id"], name: "index_seats_on_available_id"
    t.index ["train_detail_id"], name: "index_seats_on_train_detail_id"
  end

  create_table "train_details", force: :cascade do |t|
    t.string "train_code"
    t.string "from"
    t.string "to"
    t.text "days"
    t.datetime "departure_time"
    t.datetime "arrival_time"
    t.integer "distance_km"
    t.integer "travel_time_hrs"
    t.integer "class_2a_count"
    t.integer "class_2a_price"
    t.integer "class_1a_count"
    t.integer "class_1a_price"
    t.integer "class_general_count"
    t.integer "class_general_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "train_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wait_lists", force: :cascade do |t|
    t.date "dates"
    t.string "berth_class"
    t.text "passenger_names"
    t.text "wait_pnr"
    t.integer "train_detail_id", null: false
    t.integer "reservation_id", null: false
    t.integer "available_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available_id"], name: "index_wait_lists_on_available_id"
    t.index ["reservation_id"], name: "index_wait_lists_on_reservation_id"
    t.index ["train_detail_id"], name: "index_wait_lists_on_train_detail_id"
  end

  add_foreign_key "availables", "train_details"
  add_foreign_key "passengers", "reservations"
  add_foreign_key "reservations", "availables"
  add_foreign_key "reservations", "train_details"
  add_foreign_key "seats", "availables"
  add_foreign_key "seats", "train_details"
  add_foreign_key "wait_lists", "availables"
  add_foreign_key "wait_lists", "reservations"
  add_foreign_key "wait_lists", "train_details"
end
