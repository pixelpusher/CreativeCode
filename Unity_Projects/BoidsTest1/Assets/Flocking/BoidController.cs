using UnityEngine;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// these define the flock's behavior
/// </summary>
public class BoidController : MonoBehaviour
{
	public float minSpeed = 5f;
	public float maxSpeed = 20f;
	public float maxForce = 0.1f;
	public float cohesionWeight = 2f;
	public float targetAttraction = 0.1f;
	
	public float neighborDist = 10f;
	public float randomness = 1f;
	public int flockSize = 20;
	public BoidFlocking prefab;
	public Transform target;
	public GameObject[] avoidList;
	
	internal Vector3 flockCenter;
	internal Vector3 flockVelocity;
	
	
	// these are the boid objects
	List<BoidFlocking> boids = new List<BoidFlocking>();

	void Start()
	{
		for (int i = 0; i < flockSize; i++)
		{
			BoidFlocking boid = Instantiate(prefab, transform.position, transform.rotation) as BoidFlocking;
			boid.transform.parent = transform;
			boid.transform.localPosition = new Vector3(
							Random.value * collider.bounds.size.x,
							Random.value * collider.bounds.size.y,
							Random.value * collider.bounds.size.z) - collider.bounds.extents;
			
			boid.rigidbody.velocity = new Vector3(
							Random.value * maxSpeed,
							Random.value * maxSpeed,
							Random.value * maxSpeed);
			boid.rigidbody.velocity *= 0.8f;
			
			boid.target = new Vector3(collider.bounds.center.x, collider.bounds.center.y, collider.bounds.center.z);
			boid.mTargetAttraction = targetAttraction;
			boids.Add(boid);
		}
	}

	void Update()
	{
		Vector3 center = Vector3.zero;
		Vector3 velocity = Vector3.zero;
		foreach (BoidFlocking boid in boids)
		{
			boid.mMaxForce = maxForce;
			boid.mMaxSpeed = maxSpeed;
			boid.mMinSpeed = minSpeed;
			boid.mTargetAttraction = targetAttraction;
			boid.mNeighborMaxDist = neighborDist;
			boid.mCohesionWeight = cohesionWeight;
			//boid.steer(target);
			boid.flock(boids, avoidList);
			boid.move(collider.bounds);
			
			center += boid.transform.localPosition;
			velocity += boid.rigidbody.velocity;
		}
		flockCenter = center / flockSize;
		flockVelocity = velocity / flockSize; // for alignment
		
	}
}