using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class BoidFlocking : MonoBehaviour
{
	internal Vector3 acc;
	// acceleration
	internal float mTargetAttraction, mMaxSpeed, mMinSpeed, mMaxForce, mNeighborMaxDist, mCohesionWeight, mSeparationWeight;
	internal Vector3 target;
	
	void Start()
	{
		acc = new Vector3 ();
		mTargetAttraction = 0.2f;
		mMaxSpeed = 10f;
		mMaxForce = 0.1f;
		mNeighborMaxDist = 10f;
		//mNeightborMinDist = 4f;
		mCohesionWeight = 0.5f;
		mSeparationWeight = 0.3f;
	}

	/// <summary>
	/// Move the Boid's position by updating rigidbody it's attached to 
	/// </summary>
	/// <param name="maxForce">
	/// A <see cref="System.Single"/>
	/// </param>
	public void move (Bounds outerBounds)
	{
		
		Vector3 diff = target - rigidbody.transform.position;
		diff = mTargetAttraction*diff;
		rigidbody.AddRelativeForce (diff);
		
		Vector3 force = Vector3.ClampMagnitude (acc, mMaxForce);
		
		//if (outerBounds.SqrDistance(rigidbody.transform.position) < Mathf.Epsilon)
		
		if (!outerBounds.Contains(rigidbody.worldCenterOfMass))
		{
			//rigidbody.velocity = -rigidbody.velocity;
			
			//rigidbody.position = outerBounds.center;
			/*
			rigidbody.velocity = new Vector3(
							Random.value * mMaxSpeed,
							Random.value * mMaxSpeed,
							Random.value * mMaxSpeed);
							*/
		}	
		else
		{
			rigidbody.AddRelativeForce (force);
			//rigidbody.AddForceAtPosition(force, rigidbody.transform.localPosition+force.normalized*rigidbody.transform.localScale.magnitude);
			
			if (rigidbody.velocity.sqrMagnitude >  mMaxSpeed)
			{
				rigidbody.velocity = Vector3.ClampMagnitude (rigidbody.velocity, mMaxSpeed);
			} 
			else if (rigidbody.velocity.sqrMagnitude < mMinSpeed) 
			{
				rigidbody.velocity = rigidbody.velocity.normalized*mMinSpeed;
			}
		}
		
		// should set look rotation??
		rigidbody.rotation.SetLookRotation(rigidbody.velocity.normalized);
		
		// reset acceleration
		acc *= 0;
	}

	public void flock (List<BoidFlocking> boids, GameObject[] avoidList)
	{
		Vector3 velSum = new Vector3 ();
		Vector3 alignment = new Vector3 ();
		Vector3 cohesion = new Vector3 ();
		Vector3 separation = new Vector3 ();
		
		int count = 0;
		
		foreach (BoidFlocking other in boids) {
			if (this != other) {
				
				float neighborDistance = Vector3.Distance (transform.localPosition, other.rigidbody.transform.localPosition);
				if (neighborDistance < mNeighborMaxDist) 
				{
					//sum of all velocities
					velSum += other.rigidbody.velocity;
										
					//separation
					Vector3 neighborRepulsion = transform.localPosition - other.rigidbody.transform.localPosition;
					separation += neighborRepulsion.normalized / mNeighborMaxDist;
					
					//cohesion
					cohesion += other.rigidbody.transform.localPosition;
					
					count++;
				}
			}
		}
		
		// if we found any
		if (count > 0) 
		{
			float invCount = (1f / count);
			
			// average velocity of every nearby Boid
			alignment = velSum/invCount;
			
			alignment -= rigidbody.velocity;
			
			cohesion /= invCount;
			
			// Implement Reynolds: Steering = Desired - Velocity
			cohesion = rigidbody.transform.position - rigidbody.velocity - cohesion;
			 
			separation /= invCount;
			
		}
		
		acc += (0.3f*alignment + mSeparationWeight*separation + mCohesionWeight*cohesion);
	}
	
/// end class BoidFlocking
}
