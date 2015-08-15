#include "storagemanager.h"

#include <QtCore/QDirIterator>
#include <QtCore/QSettings>
#include <QtCore/QStandardPaths>
#include <QtCore/QProcess>
#include <QtCore/QDebug>

#include "qspotifysession.h"

StorageManager::StorageManager()
{
    QSettings settings;
    QString currentPath = settings.value("dataPath").toString();
    if (currentPath.startsWith("/media/sdcard")) currentLocation_ = SDCardStorage;
    else currentLocation_ = InternalStorage;
}

bool StorageManager::sdCardAvailable() const
{
    qDebug() << sdCardPath();
    return !sdCardPath().isEmpty();
}

StorageManager::StorageLocation StorageManager::currentLocation() const
{
    return currentLocation_;
}

bool StorageManager::changeLocationTo(StorageManager::StorageLocation location)
{
    if (location == currentLocation() || (SDCardStorage == location && !sdCardAvailable())) return false;

    QString fromPath = sdCardPath();
    QString toPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/harbour-cutespot/";
    if (InternalStorage != location) {
        std::swap(fromPath, toPath);
    }
    QDir toDir(toPath);
    if (!toDir.exists()) toDir.mkpath(".");
    QSettings settings;

    settings.setValue("dataPath", toPath);
    QFile loginFile(fromPath + "settings");
    if (loginFile.exists())
        loginFile.copy(toPath + "settings");
    return true;
}

bool StorageManager::canClearStorage(StorageManager::StorageLocation location) const
{
    if (location == currentLocation() && QSpotifySession::instance()->connectionStatus() != QSpotifySession::LoggedOut) return false;
    if (SDCardStorage == location && (!sdCardAvailable() || !QDir(sdCardPath()).exists())) return false;
    if (InternalStorage == location) {
        QString settingFile = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/harbour-cutespot/settings";
        if (!QFile(settingFile).exists()) return false;
    }
    return true;
}

void StorageManager::clearStorage(StorageManager::StorageLocation location)
{
    if (location == currentLocation() && QSpotifySession::instance()->connectionStatus() != QSpotifySession::LoggedOut) return;

    QString dataPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/harbour-cutespot/";
    QString execString = QString("sh -c \"find %1 -mindepth 1 -maxdepth 1 -not -name \"CuteSpot\" -exec rm -r {} \\;\"").arg(dataPath);
    if (location == SDCardStorage) {
        dataPath = sdCardPath();
        execString = QString("rm -r %1").arg(dataPath);
    }

    qDebug() << execString;
    if(!QProcess::startDetached(execString)) {
        qWarning() << "Couldn't clear cachem, startDetached failed!";
    }
}

QString StorageManager::sdCardPath() const
{
    QString sdPath;
    QDirIterator it("/media/sdcard/", QDir::NoDotAndDotDot | QDir::Dirs | QDir::Writable);
    while (it.hasNext()) {
        QString currentDir = it.next();
        QString path = currentDir.split(QDir::separator(), QString::SkipEmptyParts).last();
        if (QFile(QString("/dev/disk/by-uuid/%1").arg(path)).exists()) {
            sdPath = currentDir;
            break;
        }
    }
    if (sdPath.isEmpty()) return sdPath;

    if (!sdPath.endsWith(QDir::separator())) sdPath.append(QDir::separator());
    sdPath.append(".cache/CuteSpot/");
    return sdPath;
}
