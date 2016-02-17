FactoryGirl.define do
  factory :db, class: Mysql2Wrapper::Db do
    db_params host: '127.0.0.1',
              username: 'root',
              database: 'apr_autorizaciones_test',
              symbolize_keys: true,
              cast_booleans: true

    initialize_with { new(db_params) }
  end
end
