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
		//rigidbody.AddRelativeForce (diff);
		
		Vector3 force = Vector3.ClampMagnitude (acc, mMaxForce);
		
		force += diff;
		
		if (!outerBounds.Contains(rigidbody.worldCenterOfMass))
		{
			// a few options if it goes out of bounds...
			
			//rigidbody.velocity = -rigidbody.velocity;
			
			// respawn!
			/*rigidbody.position = outerBounds.center;
			
			rigidbody.velocity = new Vector3(
							Random.value * mMaxSpeed,
							Random.value * mMaxSpeed,
							Random.value * mMaxSpeed);
			*/
		}	
		else
		{
			// these next 3 lines rotate the capsule / prefab properly, then propel it forwards
			Vector3 dir = force.normalized;
			rigidbody.transform.rotation = Quaternion.LookRotation(dir);
			rigidbody.AddRelativeForce (force.magnitude * Vector3.forward);
			
			if (rigidbody.velocity.sqrMagnitude >  mMaxSpeed)
			{
				rigidbody.velocity = Vector3.ClampMagnitude (rigidbody.velocity, mMaxSpeed);
			} 
			else if (rigidbody.velocity.sqrMagnitude < mMinSpeed) 
			{
				rigidbody.velocity = rigidbody.velocity.normalized*mMinSpeed;
			}
		}
		
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
					//float distFactor = Mathf.Min(0.1f, 1f/(neighborDistance-mNeighborMaxDist));
					//separation += neighborRepulsion.normalized * distFactor;
					
					separation += neighborRepulsion / mNeighborMaxDist;
					
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
