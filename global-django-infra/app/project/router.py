class GlobalRegionRouter:
    """
    Directs writes to the primary (US) and reads to the local replica.
    """
    def db_for_read(self, model, **hints):
        import os
        # Read from 'replica' DB if deployed in Europe
        if os.environ.get('REGION') == 'EU':
            return 'replica'
        return 'default'

    def db_for_write(self, model, **hints):
        # Writes ALWAYS go to the primary 'default' DB
        return 'default'

    def allow_relation(self, obj1, obj2, **hints):
        return True

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        return db == 'default' # Only migrate the primary