extern crate rand;

use std::collections::{HashMap, HashSet};
use std::env::args;
use std::fs::read_to_string;

use rand::{Rng, thread_rng};
use rand::seq::SliceRandom;

fn time<'a>(route: &'a [&'a str], dists: &HashMap<(&'a str, &'a str), f64>, start: &'a str, end: &'a str) -> f64 {
    let mut dist = dists[&(start, route[0])];
    let mut curr_point = route[0];
    for p in route.iter().skip(1).take_while(|p| *p != &end) {
        dist += dists[&(curr_point, *p)];
        curr_point = p;
    }
    dist += dists[&(curr_point, end)];

    dist
}

fn main() {
    let argv: Vec<String> = args().collect();
    let data = read_to_string(&argv[1]).unwrap();
    let start: &str = &argv[2];
    let end: &str = &argv[3];

    let mut dists = HashMap::new();

    let mut points: HashSet<&str> = HashSet::new();

    for line in data.lines() {
        let parts: Vec<_> = line.split(",").collect();
        assert_eq!(parts.len(), 3);
        let (a, b, dist) = (parts[0], parts[1], parts[2]);

        // Convert &str into &'static str
        let a: &'static str = Box::leak(a.into());
        let b: &'static str = Box::leak(b.into());

        if let Ok(dist) = dist.parse::<f64>() {
            dists.insert((a, b), dist);
        }
        points.insert(a);
        points.insert(b);
    }
    assert!( points.contains(&start) );
    assert!( points.contains(&end) );
    let mut rng = thread_rng();

    let mut route: Vec<&str> = points.into_iter().collect();
    route.shuffle(&mut rng);

    let mut temp = 1e4;
    let cooling_factor = 1e-4;
    let num_points = route.len();

    let mut curr_dist = time(&route, &dists, start, end);

    while temp > 1. {
        let i = rng.gen_range(0, num_points);
        let j = loop { let j = rng.gen_range(0, num_points); if j != i { break j; } };
        let mut new_route = route.clone();
        new_route.swap(i, j);
        let new_dist = time(&new_route, &dists, start, end);
        let delta_dist = curr_dist - new_dist;

        if (delta_dist/temp).exp() > rng.gen() {
            std::mem::replace(&mut route, new_route);
            println!("New route has time of {} min", (curr_dist/1_000./60.).round());
            curr_dist = new_dist;
        }

        temp *= 1. - cooling_factor;
    }

    println!("Final route: {:?}", route);


    println!("Done");
}
