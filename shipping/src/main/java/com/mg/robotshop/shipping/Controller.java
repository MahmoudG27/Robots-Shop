package com.mg.robotshop.shipping;

import java.util.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.data.domain.Sort;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

@RestController
@RequestMapping("/shipping")
public class ShippingController {

    private static final Logger logger = LoggerFactory.getLogger(ShippingController.class);

    private final String cartUrl =
            "http://" + System.getenv().getOrDefault("CART_ENDPOINT", "cart") + "/shipping/";

    private static final List<byte[]> bytesGlobal =
            Collections.synchronizedList(new ArrayList<>());

    @Autowired
    private CityRepository cityRepo;

    @Autowired
    private CodeRepository codeRepo;

    @GetMapping("/memory")
    public int memory() {
        byte[] bytes = new byte[25 * 1024 * 1024];
        Arrays.fill(bytes, (byte) 8);
        bytesGlobal.add(bytes);
        return bytesGlobal.size();
    }

    @GetMapping("/free")
    public int free() {
        bytesGlobal.clear();
        return bytesGlobal.size();
    }

    @GetMapping("/count")
    public long count() {
        return cityRepo.count();
    }

    @GetMapping("/codes")
    public Iterable<Code> codes() {
        return codeRepo.findAll(Sort.by(Sort.Direction.ASC, "name"));
    }

    @GetMapping("/cities/{code}")
    public List<City> cities(@PathVariable String code) {
        return cityRepo.findByCode(code);
    }

    @GetMapping("/match/{code}/{text}")
    public List<City> match(@PathVariable String code, @PathVariable String text) {
        if (text.length() < 3) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "text too short");
        }
        List<City> cities = cityRepo.match(code, text);
        return cities.size() > 10 ? cities.subList(0, 10) : cities;
    }

    @GetMapping("/calc/{id}")
    public Ship calc(@PathVariable long id) {
        City city = cityRepo.findById(id);
        if (city == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "city not found");
        }

        Calculator calc = new Calculator(city);
        long distance = calc.getDistance(51.164896, 7.068792);
        double cost = Math.rint(distance * 5) / 100.0;

        return new Ship(distance, cost);
    }

    @PostMapping(value = "/confirm/{id}", consumes = "application/json", produces = "application/json")
    public String confirm(@PathVariable String id, @RequestBody String body) {
        CartHelper helper = new CartHelper(cartUrl);
        String cart = helper.addToCart(id, body);

        if (cart.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "cart not found");
        }
        return cart;
    }
}
