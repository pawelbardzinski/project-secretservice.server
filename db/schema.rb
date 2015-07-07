# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140923152043) do

  create_table "order_items", force: true do |t|
    t.integer  "order_id",   null: false
    t.integer  "product_id", null: false
    t.float    "price",      null: false
    t.integer  "quantity",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree

  create_table "orders", force: true do |t|
    t.integer  "user_id",                        null: false
    t.integer  "venue_id",                       null: false
    t.integer  "order_status",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_4",             limit: 4
    t.string   "credit_card_brand",  limit: 30
    t.integer  "venue_user_id"
    t.string   "cancel_reason",      limit: 200
    t.integer  "payment_type"
    t.string   "payment_identifier", limit: 32
    t.string   "location",           limit: 100
  end

  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree
  add_index "orders", ["venue_id", "order_status"], name: "index_orders_on_venue_id_and_order_status", using: :btree

  create_table "payment_options", force: true do |t|
    t.string   "last_4",             limit: 4
    t.string   "credit_card_brand",  limit: 30
    t.integer  "user_id",                       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment_type"
    t.string   "payment_identifier", limit: 32
    t.integer  "venue_id"
  end

  add_index "payment_options", ["user_id"], name: "index_payment_options_on_user_id", using: :btree

  create_table "products", force: true do |t|
    t.string   "name",       limit: 30,                 null: false
    t.float    "price",                                 null: false
    t.float    "rating"
    t.integer  "venue_id",                              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived",              default: false
  end

  add_index "products", ["venue_id"], name: "index_products_on_venue_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "firstname",              limit: 30,                  null: false
    t.string   "lastname",               limit: 30
    t.string   "email",                  limit: 100,                 null: false
    t.string   "mobile",                 limit: 20,                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.text     "auth_token"
    t.datetime "token_expiration"
    t.text     "password_reset_token"
    t.datetime "password_expires_after"
    t.integer  "role"
    t.integer  "venue_id"
    t.boolean  "archived",                           default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["mobile"], name: "index_users_on_mobile", using: :btree
  add_index "users", ["venue_id"], name: "index_users_on_venue_id", using: :btree

  create_table "venues", force: true do |t|
    t.string   "name",                      limit: 100,                 null: false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "address_line_1",            limit: 100,                 null: false
    t.string   "address_line_2",            limit: 100
    t.string   "city",                      limit: 100,                 null: false
    t.string   "state",                     limit: 10,                  null: false
    t.string   "zip_code",                  limit: 10,                  null: false
    t.string   "country",                   limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived",                              default: false
    t.boolean  "allow_membership_payment",              default: false
    t.boolean  "allow_credit_card_payment",             default: true
    t.boolean  "allow_cash_payment",                    default: true
  end

  add_index "venues", ["latitude"], name: "index_venues_on_latitude", using: :btree
  add_index "venues", ["longitude"], name: "index_venues_on_longitude", using: :btree
  add_index "venues", ["name"], name: "index_venues_on_name", using: :btree

end
