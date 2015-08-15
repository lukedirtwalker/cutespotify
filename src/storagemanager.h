#ifndef STORAGEMANAGER_H
#define STORAGEMANAGER_H

#include <QtCore/QObject>

class StorageManager : public QObject
{
    Q_OBJECT
public:
    enum StorageLocation {
        InternalStorage,
        SDCardStorage
    };
    Q_ENUMS(StorageLocation)

    StorageManager();

    Q_INVOKABLE bool sdCardAvailable() const;
    Q_INVOKABLE StorageLocation currentLocation() const;

    Q_INVOKABLE bool changeLocationTo(StorageLocation location);

    Q_INVOKABLE bool canClearStorage(StorageLocation location) const;
    Q_INVOKABLE void clearStorage(StorageLocation location);

private:
    void populateData();
    StorageLocation currentLocation_{};
    QString sdCardPath() const;
};

#endif // STORAGEMANAGER_H
