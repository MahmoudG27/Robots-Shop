package com.mg.robotshop.shipping;

import java.util.List;

import org.springframework.data.repository.CrudRepository;
import org.springframework.data.jpa.repository.Query;

public interface CityRepository extends CrudRepository<City, Long> {

    List<City> findByCode(String code);

    @Query("select c from City c where c.code = ?1 and c.city like CONCAT(?2, '%')")
    List<City> match(String code, String text);
}