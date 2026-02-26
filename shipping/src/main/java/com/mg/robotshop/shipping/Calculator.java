package com.mg.robotshop.shipping;

public class Calculator {

    private double latitude;
    private double longitude;

    public Calculator(double latitude, double longitude) {
        this.latitude = latitude;
        this.longitude = longitude;
    }

    public Calculator(City city) {
        this.latitude = city.getLatitude();
        this.longitude = city.getLongitude();
    }

    public long getDistance(double targetLatitude, double targetLongitude) {
        double earthRadius = 6371e3;

        double lat1 = Math.toRadians(this.latitude);
        double lat2 = Math.toRadians(targetLatitude);
        double deltaLat = Math.toRadians(targetLatitude - this.latitude);
        double deltaLon = Math.toRadians(targetLongitude - this.longitude);

        double a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2)
                + Math.cos(lat1) * Math.cos(lat2)
                * Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return Math.round((earthRadius * c) / 1000);
    }
}