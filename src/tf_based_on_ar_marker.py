#!/usr/bin/env python
import rospy
import tf

if __name__ == "__main__":
    rospy.init_node("tf_based_on_ar_marker")
    connected_marker_link = rospy.get_param("connected_marker_link", "ar_marker_link")
    ar_marker_link = rospy.get_param("ar_marker_link", "ar_marker_4")
    target_link = rospy.get_param("target_link", "head_camera")
    disconnected_target_link = rospy.get_param("disconnected_target_link", "dummy_link")

    listener = tf.TransformListener()

    while not rospy.is_shutdown():
        try:
            trans, rot = listener.lookupTransform(ar_marker_link, target_link, rospy.Time(0))
            br = tf.TransformBroadcaster()
            br.sendTransform(trans,
                            rot,
                            rospy.Time.now(),
                            disconnected_target_link,
                            connected_marker_link)
        except Exception as e:
            print e
