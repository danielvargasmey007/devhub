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

ActiveRecord::Schema[8.0].define(version: 2025_11_18_225757) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.index ["record_type", "record_id", "created_at"], name: "index_activities_on_record_type_and_record_id_and_created_at"
    t.index ["record_type", "record_id"], name: "index_activities_on_record"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.index ["name"], name: "index_projects_on_name"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "status", default: "pending", null: false
    t.bigint "project_id", null: false
    t.string "assignee_type"
    t.bigint "assignee_id"
    t.index ["assignee_type", "assignee_id"], name: "index_tasks_on_assignee"
    t.index ["assignee_type", "assignee_id"], name: "index_tasks_on_assignee_type_and_assignee_id"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["status"], name: "index_tasks_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "crypted_password", null: false
    t.string "password_salt"
    t.string "persistence_token"
    t.string "single_access_token"
    t.string "perishable_token"
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["perishable_token"], name: "index_users_on_perishable_token", unique: true
    t.index ["persistence_token"], name: "index_users_on_persistence_token", unique: true
    t.index ["single_access_token"], name: "index_users_on_single_access_token", unique: true
  end

  add_foreign_key "tasks", "projects"
end
